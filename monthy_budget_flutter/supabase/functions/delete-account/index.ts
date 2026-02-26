import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Verify the user is authenticated
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing authorization" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Client-level supabase to get the current user
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } }
    );

    const {
      data: { user },
      error: authError,
    } = await supabaseClient.auth.getUser();

    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Admin-level supabase to delete user data and auth record
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { auth: { autoRefreshToken: false, persistSession: false } }
    );

    const userId = user.id;

    // Look up the user's household membership
    const { data: membership } = await supabaseAdmin
      .from("household_members")
      .select("household_id, role")
      .eq("user_id", userId)
      .maybeSingle();

    const householdId = membership?.household_id;

    // Delete user-related data from all tables
    if (householdId) {
      // If user is the only member or admin, clean household data
      const { count } = await supabaseAdmin
        .from("household_members")
        .select("*", { count: "exact", head: true })
        .eq("household_id", householdId);

      if (count !== null && count <= 1) {
        // Last member — delete all household data
        await supabaseAdmin
          .from("household_coach_insights")
          .delete()
          .eq("household_id", householdId);
        await supabaseAdmin
          .from("shopping_list")
          .delete()
          .eq("household_id", householdId);
        await supabaseAdmin
          .from("purchase_records")
          .delete()
          .eq("household_id", householdId);
        await supabaseAdmin
          .from("household_settings")
          .delete()
          .eq("household_id", householdId);
        await supabaseAdmin
          .from("household_favorites")
          .delete()
          .eq("household_id", householdId);
        await supabaseAdmin
          .from("expense_snapshots")
          .delete()
          .eq("household_id", householdId);
        await supabaseAdmin
          .from("meal_plans")
          .delete()
          .eq("household_id", householdId);
        await supabaseAdmin
          .from("household_invite_codes")
          .delete()
          .eq("household_id", householdId);
        await supabaseAdmin
          .from("households")
          .delete()
          .eq("id", householdId);
      }

      // Remove this user's membership
      await supabaseAdmin
        .from("household_members")
        .delete()
        .eq("user_id", userId);
    }

    // Delete the user from Supabase Auth
    const { error: deleteError } =
      await supabaseAdmin.auth.admin.deleteUser(userId);

    if (deleteError) {
      return new Response(
        JSON.stringify({ error: `Failed to delete user: ${deleteError.message}` }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    return new Response(
      JSON.stringify({ success: true }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

# Orçamento Mensal — Monetization Strategy

## App Overview

**Orçamento Mensal** is a comprehensive personal finance & household management app built with Flutter, targeting European (primarily Portuguese) markets. It combines budgeting, expense tracking, meal planning, grocery management, and AI-powered financial coaching into a single platform.

### Key Stats

| Metric | Value |
|--------|-------|
| Codebase size | 97 files, ~44,000 lines of Dart |
| Screens | 17+ screens |
| Services | 19 service classes |
| Languages | 4 (PT, EN, ES, FR) |
| Tax systems | 4 countries (PT, ES, FR, UK) |
| Backend | Supabase (Auth, DB, Realtime) |
| AI integration | OpenAI GPT-4o-mini |

---

## 1. App Valuation

### Development Cost to Rebuild

If you were to hire a team to rebuild this app from scratch:

| Component | Estimated Cost |
|-----------|---------------|
| Core budgeting engine + tax systems (4 countries) | $8,000–$12,000 |
| Supabase backend + auth + household sharing | $4,000–$6,000 |
| Meal planner + AI recipe generation | $5,000–$8,000 |
| Grocery catalog + shopping list (real-time) | $3,000–$5,000 |
| AI financial coach integration | $3,000–$5,000 |
| Charts, analytics, savings projections | $3,000–$5,000 |
| Localization (4 languages) | $2,000–$3,000 |
| Onboarding, tours, export (PDF/CSV) | $2,000–$4,000 |
| UI/UX design (5 palettes, dark/light) | $3,000–$5,000 |
| **Total rebuild cost** | **$33,000–$53,000** |

### Market Value (as a Google Play listing)

| Scenario | Value Range | Notes |
|----------|-------------|-------|
| Codebase only (no users) | $2,000–$8,000 | Sale on Flippa/CodeCanyon |
| With 1K–5K active users | $5,000–$20,000 | Early traction |
| With 10K–50K active users | $20,000–$80,000 | Proven product-market fit |
| With 50K+ users + revenue | $100,000+ | Acquisition target |

### Revenue Potential (monthly)

| Strategy | Conservative | Moderate | Optimistic |
|----------|-------------|----------|------------|
| Ads only (10K users) | $100–$300/mo | $300–$800/mo | $800–$1,500/mo |
| Freemium subscriptions (10K users, 3% conversion) | $600–$1,200/mo | $1,200–$3,000/mo | $3,000–$6,000/mo |
| Hybrid (ads + subscriptions) | $800–$1,500/mo | $1,500–$4,000/mo | $4,000–$8,000/mo |

---

## 2. Competitive Landscape

### Direct Competitors (Europe / Portugal)

| App | Model | Price | Differentiator |
|-----|-------|-------|----------------|
| **YNAB** | Subscription | $14.99/mo | Methodology-driven budgeting |
| **Wallet by BudgetBakers** | Freemium | €5.99/mo | Bank sync, multi-currency |
| **1Money** | Freemium | €3.49/mo | Simple UI, emerging markets |
| **Goodbudget** | Freemium | $8/mo | Envelope budgeting |
| **Monefy** | One-time + subscription | €2.99 + €1.49/mo | Ultra-simple expense tracking |

### Your Competitive Advantages

1. **Multi-country tax system** — No competitor integrates PT/ES/FR/UK IRS tables directly
2. **Meal planning + budget** — Unique cross-domain integration
3. **AI financial coaching** — Premium feature most competitors lack
4. **Real-time household collaboration** — Supabase Realtime shopping lists
5. **Portuguese-first** — Native experience for an underserved market
6. **Financial stress index** — Unique health metric

---

## 3. Recommended Monetization Model: Freemium + Ads

### Tier Structure

#### Free Tier (Ad-Supported)
Users get a fully functional budgeting experience:

- ✅ Monthly budget calculator
- ✅ Up to 8 budget categories
- ✅ Basic expense tracking (current month only)
- ✅ 1 savings goal
- ✅ Shopping list (no real-time sync — local only)
- ✅ Grocery product browser
- ✅ Tax calculator (home country only)
- ✅ Banner ads on dashboard
- ✅ Interstitial ads when exporting

#### Premium Tier — €3.99/mo or €29.99/yr
Power users and families:

- ✅ Everything in Free
- ✅ **Unlimited budget categories**
- ✅ **Full expense history + trends**
- ✅ **Unlimited savings goals + projections**
- ✅ **AI Financial Coach** (this is the premium anchor)
- ✅ **Meal planner + AI recipes**
- ✅ **Real-time collaborative shopping list**
- ✅ **PDF/CSV export**
- ✅ **Recurring expense management**
- ✅ **Bill reminders (notifications)**
- ✅ **No ads**

#### Family/Pro Tier — €6.99/mo or €49.99/yr
Households and power users:

- ✅ Everything in Premium
- ✅ **Household sharing** (up to 6 members)
- ✅ **Multi-country tax simulator** (all 4 countries)
- ✅ **Budget streaks + stress index**
- ✅ **Month-in-review reports**
- ✅ **Dashboard customization**
- ✅ **Priority AI coaching** (more queries per month)
- ✅ **All 5 color themes**

### Why This Structure Works

- **Free tier is useful enough** to attract users and get good reviews
- **AI Coach is the premium anchor** — it's the hardest to replicate and has ongoing cost (OpenAI tokens)
- **Meal planning is a differentiator** — gates a unique feature behind the paywall
- **Family tier justifies higher price** — multi-user features have clear value
- **Annual discount (37% off)** encourages long-term commitment

---

## 4. Implementation Roadmap

### Phase 1: Foundation (Week 1–2)
- [ ] Add `google_mobile_ads` package for AdMob integration
- [ ] Add `purchases_flutter` (RevenueCat) or `in_app_purchase` for subscription billing
- [ ] Create `SubscriptionService` to manage tier state
- [ ] Create `PaywallScreen` with tier comparison UI
- [ ] Add Firebase Analytics (`firebase_analytics`) for user behavior tracking
- [ ] Implement feature-gating logic throughout the app

### Phase 2: Ad Integration (Week 2–3)
- [ ] Register for Google AdMob account
- [ ] Create ad units (banner, interstitial, rewarded)
- [ ] Add banner ad widget to Dashboard bottom
- [ ] Add interstitial ads before export actions
- [ ] Add optional rewarded ads ("Watch ad to unlock 1 AI insight")
- [ ] Implement ad removal for premium users

### Phase 3: Subscription Flow (Week 3–4)
- [ ] Configure Google Play Console for subscriptions
- [ ] Configure App Store Connect for subscriptions (iOS)
- [ ] Build subscription purchase flow with RevenueCat
- [ ] Implement receipt validation
- [ ] Add subscription status checks at feature gates
- [ ] Handle subscription lifecycle (renewal, cancellation, grace period)
- [ ] Add restore purchases functionality

### Phase 4: Feature Gating (Week 4–5)
- [ ] Gate AI Coach behind Premium tier
- [ ] Gate Meal Planner behind Premium tier
- [ ] Gate expense history/trends behind Premium tier
- [ ] Gate household features behind Family tier
- [ ] Gate multi-country tax behind Family tier
- [ ] Limit free tier to 8 categories, 1 savings goal
- [ ] Gate PDF/CSV export behind Premium tier
- [ ] Show upgrade prompts at gate points

### Phase 5: Store Optimization (Week 5–6)
- [ ] Create professional app icon (replace default Flutter icon)
- [ ] Design store screenshots (phone + tablet, all 4 languages)
- [ ] Write compelling store description (PT, EN, ES, FR)
- [ ] Create feature graphic (1024x500)
- [ ] Set up store listing experiments (A/B test descriptions)
- [ ] Configure pricing for each target market

### Phase 6: Launch & Iterate (Week 6+)
- [ ] Soft launch in Portugal (primary market)
- [ ] Monitor analytics (retention, conversion, ARPU)
- [ ] A/B test paywall designs
- [ ] Expand to Spain, France, UK
- [ ] Iterate on tier features based on user feedback
- [ ] Consider promotional pricing (first month free)

---

## 5. Technical Implementation Details

### Packages to Add

```yaml
# pubspec.yaml additions
dependencies:
  # Monetization
  google_mobile_ads: ^5.3.0        # AdMob ads
  purchases_flutter: ^8.0.0        # RevenueCat subscriptions

  # Analytics
  firebase_core: ^3.8.0            # Firebase base
  firebase_analytics: ^11.4.0      # User analytics
  firebase_crashlytics: ^4.2.0     # Crash reporting

  # Store
  in_app_review: ^2.0.0            # Prompt for reviews
  package_info_plus: ^8.0.0        # Version info
```

### Subscription Service Architecture

```dart
// lib/services/subscription_service.dart

enum SubscriptionTier { free, premium, family }

class SubscriptionService {
  // Check current user tier
  Future<SubscriptionTier> getCurrentTier();

  // Feature gate checks
  bool canUseAICoach(SubscriptionTier tier);      // Premium+
  bool canUseMealPlanner(SubscriptionTier tier);   // Premium+
  bool canUseHousehold(SubscriptionTier tier);      // Family
  bool canExport(SubscriptionTier tier);            // Premium+
  bool shouldShowAds(SubscriptionTier tier);        // Free only
  int maxSavingsGoals(SubscriptionTier tier);       // Free=1, Premium+=unlimited
  int maxCategories(SubscriptionTier tier);         // Free=8, Premium+=unlimited

  // Purchase flow
  Future<void> purchaseSubscription(String productId);
  Future<void> restorePurchases();
}
```

### Ad Placement Strategy

| Location | Ad Type | Frequency | Tier |
|----------|---------|-----------|------|
| Dashboard bottom | Banner (320x50) | Always visible | Free only |
| Before export | Interstitial | Every export | Free only |
| AI Coach unlock | Rewarded video | On demand | Free (1 free insight) |
| Between meal plans | Native ad | Every 3rd recipe | Free only |
| Settings footer | Banner (320x50) | Always visible | Free only |

---

## 6. Revenue Projections (Year 1)

### Assumptions
- Target: 10,000 downloads in first 6 months (Portugal focus)
- DAU/MAU ratio: 30% (finance apps average)
- Free-to-premium conversion: 3–5%
- Ad eCPM: €1.50–€3.00 (European market)

### Projected Revenue (Monthly, at 10K users)

| Source | Month 1–3 | Month 4–6 | Month 7–12 |
|--------|-----------|-----------|------------|
| AdMob (banner + interstitial) | €100–€200 | €200–€400 | €400–€800 |
| Premium subscriptions (3% × €3.99) | €120–€200 | €400–€800 | €800–€1,600 |
| Family subscriptions (1% × €6.99) | €70–€140 | €200–€400 | €400–€700 |
| **Monthly total** | **€290–€540** | **€800–€1,600** | **€1,600–€3,100** |
| **Annual total (Year 1)** | | | **€12,000–€25,000** |

### Costs to Consider

| Cost | Monthly |
|------|---------|
| Supabase (Pro plan) | €25 |
| OpenAI API (if server-side) | €50–€200 |
| RevenueCat | Free up to $2.5K MRR |
| AdMob | Free (Google takes 40%) |
| Google Play Developer fee | €25 one-time |
| Apple Developer fee | €99/year |
| **Total monthly cost** | **€75–€225** |

---

## 7. Quick Wins (Start Making Money This Week)

1. **Tip jar / Donation button** — Add a "Buy me a coffee" button in Settings. Zero infrastructure needed. Use a simple payment link.

2. **Remove the user-managed API key** — Move OpenAI calls server-side (Supabase Edge Function) and gate behind subscription. This is currently "leaking" your premium feature for free.

3. **AdMob banner on dashboard** — Single fastest path to revenue. Can be implemented in a day.

4. **Export paywall** — Gate PDF/CSV export behind a one-time "unlock" purchase (€2.99). Low friction, high perceived value.

---

## 8. Key Metrics to Track

| Metric | Target | Tool |
|--------|--------|------|
| Daily Active Users (DAU) | 3,000+ | Firebase Analytics |
| Retention (D7) | >25% | Firebase Analytics |
| Free-to-Premium conversion | >3% | RevenueCat Dashboard |
| Average Revenue Per User (ARPU) | >€0.15/mo | RevenueCat + AdMob |
| Ad eCPM | >€2.00 | AdMob Dashboard |
| App Store rating | >4.3 stars | Play Console |
| Churn rate (monthly) | <8% | RevenueCat Dashboard |

---

## Summary

Your app has **strong monetization potential** due to its unique combination of budgeting + meal planning + AI coaching, and its focus on an underserved European market. The estimated **Year 1 revenue with 10K users is €12,000–€25,000**, with a rebuild cost of **€33,000–€53,000** making this a valuable asset.

The recommended approach is a **3-tier freemium model with ads**, using **RevenueCat** for subscription management and **Google AdMob** for ad monetization. Start with Phase 1 (foundation) and Phase 7 (quick wins) in parallel.

# Supermarket Scraper (PT)

Run:

```powershell
node scripts/scrape_supermarkets_and_generate_updates.cjs
```

Outputs:

- `generated/product_price_updates.sql` -> SQL script to update `products.avg_price` and insert newly discovered products.
- `generated/product_price_updates_report.json` -> detailed report with matched stores, prices, and scrape metadata.

Notes:

- Uses store search endpoints for Continente, Auchan, Pingo Doce, Minipreco and Lidl.
- Uses Aldi homepage featured products (Aldi PT does not expose a broad public searchable price feed).
- Always review generated SQL before applying in production.

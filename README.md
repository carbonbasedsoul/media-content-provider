# Media Content Provider DWH Design

[Interactive diagram](https://dbdiagram.io/e/694486be4bbde0fd74c29400/694494484bbde0fd74c313c2)

## 1. Fact tables

| Fact table | Granularity |
|------------|-------------|
| Fact_Subscription | One subscription by one user |
| Fact_Voucher_Distribution | One voucher sold at one store |
| Fact_Voucher_Activation | One voucher activated by one user |
| Fact_Media_Viewing | One viewing session |
| Fact_Content_Purchase | One purchase/rental transaction |
| Fact_Referral | One referral (user A → user B) |
| Fact_Tariff_Change | One tariff change by one user |

<details>
<summary><b>Fact_Subscription</b></summary>

**Foreign Keys:**
- date_key → Dim_Date
- user_key → Dim_User
- tariff_key → Dim_Tariff
- geography_key → Dim_Geography
- voucher_key → Dim_Voucher (nullable)
- tv_store_key → Dim_TV_Store (nullable)
- referrer_user_key → Dim_User (nullable)

**Metrics:**
- subscription_count (always 1)
- subscription_amount
- subscription_duration_months
- is_active
</details>

<details>
<summary><b>Fact_Voucher_Distribution</b></summary>

**Foreign Keys:**
- date_key → Dim_Date
- voucher_key → Dim_Voucher
- tv_store_key → Dim_TV_Store
- geography_key → Dim_Geography

**Metrics:**
- voucher_count (always 1)
- potential_customer_age
- potential_customer_gender
</details>

<details>
<summary><b>Fact_Voucher_Activation</b></summary>

**Foreign Keys:**
- date_key → Dim_Date
- user_key → Dim_User
- voucher_key → Dim_Voucher
- geography_key → Dim_Geography

**Metrics:**
- activation_count (always 1)
- days_from_distribution_to_activation
- is_converted
</details>

<details>
<summary><b>Fact_Media_Viewing</b></summary>

**Foreign Keys:**
- date_key → Dim_Date
- user_key → Dim_User
- profile_key → Dim_Profile
- tariff_key → Dim_Tariff
- geography_key → Dim_Geography
- content_key → Dim_Media_Content
- device_key → Dim_Device

**Metrics:**
- session_count (always 1)
- viewing_duration_seconds
- is_completed
- viewing_hour
- concurrent_locations_count
</details>

<details>
<summary><b>Fact_Content_Purchase</b></summary>

**Foreign Keys:**
- date_key → Dim_Date
- user_key → Dim_User
- profile_key → Dim_Profile
- geography_key → Dim_Geography
- content_key → Dim_Media_Content
- copyright_owner_key → Dim_Copyright_Owner

**Metrics:**
- purchase_count (always 1)
- purchase_amount
- rental_amount
- is_rental
- copyright_owner_fee
</details>

<details>
<summary><b>Fact_Referral</b></summary>

**Foreign Keys:**
- date_key → Dim_Date
- referrer_user_key → Dim_User
- referred_user_key → Dim_User
- geography_key → Dim_Geography

**Metrics:**
- referral_count (always 1)
- bonus_amount_direct
- bonus_amount_indirect
- referral_depth_level
</details>

<details>
<summary><b>Fact_Tariff_Change</b></summary>

**Foreign Keys:**
- date_key → Dim_Date
- user_key → Dim_User
- old_tariff_key → Dim_Tariff
- new_tariff_key → Dim_Tariff (nullable if cancellation)
- geography_key → Dim_Geography

**Metrics:**
- change_count (always 1)
- is_upgrade
- is_downgrade
- is_cancellation
</details>


## 2. Dimension tables

| Dimension | Description | SCD Type |
|-----------|-------------|----------|
| Dim_Date | Calendar dates | Type 0 |
| Dim_User | Customers | Type 2 |
| Dim_Profile | Family profiles | Type 1 |
| Dim_Tariff | Subscription plans | Type 1 |
| Dim_Geography | Locations | Type 0 |
| Dim_Media_Content | Channels, movies, shows | Type 1 |
| Dim_Device | User devices | Type 1 |
| Dim_Voucher | Trial vouchers | Type 0 |
| Dim_Copyright_Owner | Content rights holders | Type 2 |
| Dim_TV_Store | Retail partners | Type 2 |

<details>
<summary><b>Dim_Date</b></summary>

- date_key (PK)
- full_date
- year
- month
- day
- is_weekend
</details>

<details>
<summary><b>Dim_User (SCD Type 2)</b></summary>

- user_key (PK)
- user_id (NK)
- geography_key (FK)
- age
- gender
- registration_date
- effective_date
- end_date
- is_current

*Registration_date: for potential cohort analysis
</details>

<details>
<summary><b>Dim_Profile</b></summary>

- profile_key (PK)
- profile_id (NK)
- user_key (FK)
- age
- gender
- parental_control_enabled

*Parental control: indicates kid profiles vs adult profiles*
</details>

<details>
<summary><b>Dim_Tariff</b></summary>

- tariff_key (PK)
- tariff_id (NK)
- tariff_name
- tariff_category
- duration_months
- price

*Tariff_category: Basic/Standard/Premium for segmentation*
</details>

<details>
<summary><b>Dim_Geography</b></summary>

- geography_key (PK)
- country
- region
- city
- population
</details>

<details>
<summary><b>Dim_Media_Content</b></summary>

- content_key (PK)
- content_id (NK)
- content_title
- content_type
- genre
- release_year
- copyright_owner_key (FK)

*Release_year: analyze preference for new vs classic content*
</details>

<details>
<summary><b>Dim_Device</b></summary>

- device_key (PK)
- device_id (NK)
- device_type
- os_type

*OS_type: Android/iOS/webOS - platform-specific issues tracking*
</details>

<details>
<summary><b>Dim_Voucher</b></summary>

- voucher_key (PK)
- voucher_id (NK)
- voucher_value
</details>

<details>
<summary><b>Dim_Copyright_Owner (SCD Type 2)</b></summary>

- copyright_owner_key (PK)
- copyright_owner_id (NK)
- owner_name
- default_fee_percentage
- effective_date
- end_date
- is_current
</details>

<details>
<summary><b>Dim_TV_Store (SCD Type 2)</b></summary>

- tv_store_key (PK)
- tv_store_id (NK)
- store_name
- geography_key (FK)
- effective_date
- end_date
- is_current
</details>


## 3. Bus matrix

| Fact Table | Date | User | Profile | Tariff | Geography | Content | Device | Voucher | Copyright | TV Store |
|------------|------|------|---------|--------|-----------|---------|--------|---------|-----------|----------|
| Subscription | ✓ | ✓ | | ✓ | ✓ | | | ✓ | | ✓ |
| Voucher_Distribution | ✓ | | | | ✓ | | | ✓ | | ✓ |
| Voucher_Activation | ✓ | ✓ | | | ✓ | | | ✓ | | |
| Media_Viewing | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | | | |
| Content_Purchase | ✓ | ✓ | ✓ | | ✓ | ✓ | | | ✓ | |
| Referral | ✓ | ✓ | | | ✓ | | | | | |
| Tariff_Change | ✓ | ✓ | | ✓ | ✓ | | | | | |

**Conformed dimensions:** Date, User, Geography, Tariff, Media_Content


## 4. Aggregate tables

### Agg_Monthly_Active_Subscriptions
**Purpose:** Active subscriptions at month start

**Columns:**
- month_key (PK, FK → Dim_Date)
- geography_key (PK, FK → Dim_Geography)
- tariff_key (PK, FK → Dim_Tariff)
- active_subscriptions_count
- total_revenue

### Agg_Daily_Content_Stats
**Purpose:** Content popularity metrics

**Columns:**
- date_key (PK, FK → Dim_Date)
- content_key (PK, FK → Dim_Media_Content)
- total_viewing_seconds
- unique_viewers
- total_sessions
- completion_rate


## 5. Coverage of analytical requirements

### Sales

| Requirement | Tables | Key Attributes |
|-------------|--------|----------------|
| Статистика оформлення підписок в розрізі тарифів, строків, географії | Fact_Subscription, Dim_Tariff, Dim_Geography, Dim_Date | tariff_name, duration_months, subscription_amount, city, country |
| Кількість активних підписок на початок місяця по регіонах | Agg_Monthly_Active_Subscriptions або Fact_Subscription | is_active, month_key, geography_key |
| Скільки і яких фільмів куплено/орендовано з прив'язкою до власників прав | Fact_Content_Purchase, Dim_Media_Content, Dim_Copyright_Owner | content_title, content_type, owner_name, copyright_owner_fee |
| Аналіз зміни тарифів: переходи, непродовження | Fact_Tariff_Change, Dim_Tariff | is_upgrade, is_downgrade, is_cancellation, old_tariff_key, new_tariff_key |

### Marketing

| Requirement | Tables | Key Attributes |
|-------------|--------|----------------|
| Загальна кількість ваучерів по точках розповсюдження та профілям клієнтів | Fact_Voucher_Distribution, Dim_TV_Store, Dim_Geography | store_name, potential_customer_age, potential_customer_gender |
| Конвертація ваучерів: активовано, конвертовано, час конвертації | Fact_Voucher_Activation, Fact_Voucher_Distribution | is_converted, days_from_distribution_to_activation |
| Ефективність акції "приведи друга" | Fact_Referral, Dim_User | referral_count, bonus_amount_direct, bonus_amount_indirect, referral_depth_level |
| Аналіз співпраці з магазинами ТВ | Fact_Subscription, Dim_TV_Store | tv_store_key (в Fact_Subscription), store_name |
| Регіони з малим охопленням відповідно до демографії | Всі facts, Dim_Geography | population, country, region, city |

### Product dev

| Requirement | Tables | Key Attributes |
|-------------|--------|----------------|
| Найбільш затребуваний контент: час перегляду | Fact_Media_Viewing, Dim_Media_Content, Agg_Daily_Content_Stats | viewing_duration_seconds, content_title, content_type, genre |
| Демографічні характеристики користувачів + пристрої + пора доби | Fact_Media_Viewing, Dim_Profile, Dim_Device, Dim_Date | age, gender, device_type, viewing_hour |

### Fraud

| Requirement | Tables | Key Attributes |
|-------------|--------|----------------|
| Зловживання: споживання контенту одночасно з різних геолокацій | Fact_Media_Viewing, Dim_User, Dim_Profile | concurrent_locations_count, user_key, profile_key |


## 6. Design decisions

**Star schema architecture is used for simplicity and query performance.** Dimensions are denormalized and connected directly to fact tables, minimizing JOIN depth and making queries intuitive for analysts.

**Surrogate keys (INT/BIGINT) are used as primary keys in all tables.** This approach supports SCD Type 2 implementation, ensures fast JOIN operations, and avoids conflicts when integrating data from multiple sources.

**Atomic granularity is maintained in all fact tables.** Each fact table stores the most detailed level of data available, allowing aggregation to any level while preventing loss of detail that cannot be recovered.

**SCD Type 2 is implemented for User, Copyright_Owner, and TV_Store dimensions.** These entities experience changes that require historical tracking - users relocate, contract terms evolve, and partnership conditions change. The effective_date, end_date, and is_current fields enable point-in-time analysis.

**All metrics are additive across dimensions.** This design choice ensures that metrics can be reliably summed using GROUP BY on any combination of dimensions without producing incorrect results.

**Conformed dimensions (Date, User, Geography, Tariff, Media_Content) are shared across multiple fact tables.** This enables consistent analysis across different business processes and supports drill-across queries combining data from multiple facts.

**Aggregate tables pre-calculate frequently accessed metrics.** Monthly subscription snapshots and daily content statistics improve query performance for common analytical workloads while maintaining atomic detail in base fact tables.


## 7. Implementation notes

**Data types:**
- Surrogate keys: INT for dimensions, BIGINT for facts
- Metrics: DECIMAL for money, INT for counts, BOOLEAN for flags
- Dates: DATE for dimension attributes, INT (YYYYMMDD) for fact table keys

// dimensions

Table dim_date {
  date_key int [pk]
  full_date date
  year int
  month int
  day int
  is_weekend boolean
}

Table dim_user {
  user_key int [pk]
  user_id varchar [unique]
  geography_key int [ref: > dim_geography.geography_key]
  age int
  gender varchar
  registration_date date
  effective_date date
  end_date date
  is_current boolean
  Note: 'SCD Type 2 - tracks location changes'
}

Table dim_profile {
  profile_key int [pk]
  profile_id varchar [unique]
  user_key int [ref: > dim_user.user_key]
  age int
  gender varchar
  parental_control_enabled boolean
}

Table dim_tariff {
  tariff_key int [pk]
  tariff_id varchar [unique]
  tariff_name varchar
  tariff_category varchar
  duration_months int
  price decimal
}

Table dim_geography {
  geography_key int [pk]
  country varchar
  region varchar
  city varchar
  population int
}

Table dim_media_content {
  content_key int [pk]
  content_id varchar [unique]
  content_title varchar
  content_type varchar
  genre varchar
  release_year int
  copyright_owner_key int [ref: > dim_copyright_owner.copyright_owner_key]
}

Table dim_device {
  device_key int [pk]
  device_id varchar [unique]
  device_type varchar
  os_type varchar
}

Table dim_voucher {
  voucher_key int [pk]
  voucher_id varchar [unique]
  voucher_value decimal
}

Table dim_copyright_owner {
  copyright_owner_key int [pk]
  copyright_owner_id varchar [unique]
  owner_name varchar
  default_fee_percentage decimal
  effective_date date
  end_date date
  is_current boolean
  Note: 'SCD Type 2 - contract terms change'
}

Table dim_tv_store {
  tv_store_key int [pk]
  tv_store_id varchar [unique]
  store_name varchar
  geography_key int [ref: > dim_geography.geography_key]
  effective_date date
  end_date date
  is_current boolean
  Note: 'SCD Type 2 - partnership terms change'
}

// facts

Table fact_subscription {
  subscription_key bigint [pk]
  date_key int [ref: > dim_date.date_key]
  user_key int [ref: > dim_user.user_key]
  tariff_key int [ref: > dim_tariff.tariff_key]
  geography_key int [ref: > dim_geography.geography_key]
  voucher_key int [ref: > dim_voucher.voucher_key]
  tv_store_key int [ref: > dim_tv_store.tv_store_key]
  referrer_user_key int [ref: > dim_user.user_key]
  subscription_count int
  subscription_amount decimal
  subscription_duration_months int
  is_active boolean
}

Table fact_voucher_distribution {
  voucher_distribution_key bigint [pk]
  date_key int [ref: > dim_date.date_key]
  voucher_key int [ref: > dim_voucher.voucher_key]
  tv_store_key int [ref: > dim_tv_store.tv_store_key]
  geography_key int [ref: > dim_geography.geography_key]
  voucher_count int
  potential_customer_age int
  potential_customer_gender varchar
}

Table fact_voucher_activation {
  voucher_activation_key bigint [pk]
  date_key int [ref: > dim_date.date_key]
  user_key int [ref: > dim_user.user_key]
  voucher_key int [ref: > dim_voucher.voucher_key]
  geography_key int [ref: > dim_geography.geography_key]
  activation_count int
  days_from_distribution_to_activation int
  is_converted boolean
}

Table fact_media_viewing {
  viewing_key bigint [pk]
  date_key int [ref: > dim_date.date_key]
  user_key int [ref: > dim_user.user_key]
  profile_key int [ref: > dim_profile.profile_key]
  tariff_key int [ref: > dim_tariff.tariff_key]
  geography_key int [ref: > dim_geography.geography_key]
  content_key int [ref: > dim_media_content.content_key]
  device_key int [ref: > dim_device.device_key]
  session_count int
  viewing_duration_seconds int
  is_completed boolean
  viewing_hour int
  concurrent_locations_count int
}

Table fact_content_purchase {
  purchase_key bigint [pk]
  date_key int [ref: > dim_date.date_key]
  user_key int [ref: > dim_user.user_key]
  profile_key int [ref: > dim_profile.profile_key]
  geography_key int [ref: > dim_geography.geography_key]
  content_key int [ref: > dim_media_content.content_key]
  copyright_owner_key int [ref: > dim_copyright_owner.copyright_owner_key]
  purchase_count int
  purchase_amount decimal
  rental_amount decimal
  is_rental boolean
  copyright_owner_fee decimal
}

Table fact_referral {
  referral_key bigint [pk]
  date_key int [ref: > dim_date.date_key]
  referrer_user_key int [ref: > dim_user.user_key]
  referred_user_key int [ref: > dim_user.user_key]
  geography_key int [ref: > dim_geography.geography_key]
  referral_count int
  bonus_amount_direct decimal
  bonus_amount_indirect decimal
  referral_depth_level int
}

Table fact_tariff_change {
  tariff_change_key bigint [pk]
  date_key int [ref: > dim_date.date_key]
  user_key int [ref: > dim_user.user_key]
  old_tariff_key int [ref: > dim_tariff.tariff_key]
  new_tariff_key int [ref: > dim_tariff.tariff_key]
  geography_key int [ref: > dim_geography.geography_key]
  change_count int
  is_upgrade boolean
  is_downgrade boolean
  is_cancellation boolean
}

// aggs

Table agg_monthly_active_subscriptions {
  month_key int [pk, ref: > dim_date.date_key]
  geography_key int [pk, ref: > dim_geography.geography_key]
  tariff_key int [pk, ref: > dim_tariff.tariff_key]
  active_subscriptions_count int
  total_revenue decimal
}

Table agg_daily_content_stats {
  date_key int [pk, ref: > dim_date.date_key]
  content_key int [pk, ref: > dim_media_content.content_key]
  total_viewing_seconds bigint
  unique_viewers int
  total_sessions int
  completion_rate decimal
}

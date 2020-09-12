require "date"
def rand_future_date(to)      
    now = DateTime.now
    #date_today = DateTime.parse(now.strftime("%Y-%m-%dT12:00:00%z"))      
    date_today = DateTime.parse(now.strftime("%Y-%m-%d"))      
    date_today.next_day(to)    
end

def rand_past_date(back_days, back_months)
    now = DateTime.now
    date_today = DateTime.parse(now.strftime("%Y-%m-%d"))  
    date_today.prev_day(back_days) << back_months
end

# #detete payments
Payment.all.destroy_all
# #delete leases
Lease.all.destroy_all
# #delete property addresses
PropertyAddress.all.destroy_all
# #delete all comments
Comment.all.destroy_all

# byebug
if LeaseType.all.length() == 0
    #create lease types
    ActiveRecord::Base.transaction do
        LeaseType.new(lease_type: "1M", duration_months: 1).save
    end
    ActiveRecord::Base.transaction do
        LeaseType.new(lease_type: "3M", duration_months: 3).save
    end
    ActiveRecord::Base.transaction do
        LeaseType.new(lease_type: "6M", duration_months: 6).save
    end
    ActiveRecord::Base.transaction do
        LeaseType.new(lease_type: "9M", duration_months: 9).save
    end
    ActiveRecord::Base.transaction do
        LeaseType.new(lease_type: "12M", duration_months: 12).save
    end
    ActiveRecord::Base.transaction do
        LeaseType.new(lease_type: "24M", duration_months: 24).save
    end
end    

#create a few renters
users = []
if User.all.length() < 10
    #create a few users    
    for i in 1..10 do
        users.push(User.create(
            username: Faker::Internet.username(specifier: 5..8),
            firstname: Faker::Name.first_name,
            lastname: Faker::Name.last_name,
            admin: false,
            password_digest: User.digest('foobar')
        ))
    end
end

#create user_contacts for each user
temp_users = User.all[2..11]
if UserContact.all.count == 0
    for for_user in temp_users do
        UserContact.create(
            street_address: Faker::Address.street_address,
            city: Faker::Address.city,
            state: Faker::Address.state_abbr,
            zip: Faker::Address.zip_code,
            phone: Faker::PhoneNumber.cell_phone,
            email: Faker::Internet.email,
            user_id: for_user.id,
            address_type: "PRIOR"    
        )
    end
end

#create a few properties

p_street = Faker::Address.street_address
p_city = Faker::Address.city
p_state = Faker::Address.state_abbr
p_zip = Faker::Address.zip_code

properties = []
if PropertyAddress.all.count == 0
    for i in 1..10
        properties.push(PropertyAddress.create(
        street_address: p_street,
        apartment: i,
        city: p_city,
        state: p_state,
        zip: p_zip,
        ))
    end
end

#create a few leases
# to see decimal types use .to_digits
#  this function returns a string representation 
monthly_price_options = [1450.00, 1600.00, 2150.00, 1795.00]
leases = []
user_count = 0
for for_property in properties do
    lease_type_count = rand(LeaseType.all.count)
    lease_type_random = LeaseType.offset(lease_type_count).first
    start_date = rand_future_date(30)
    end_date = start_date >> lease_type_random.duration_months
    monthly_rent = monthly_price_options[rand(monthly_price_options.count)]
    leases.push(Lease.create(
        user_id: temp_users[user_count].id,
        lease_type_id: lease_type_random.id,
        status: true,
        monthly_rent_price: monthly_rent,
        balance: 0.0,
        property_address_id: for_property.id,
        start_date: start_date,
        end_date: end_date,
        first_month_rent: monthly_rent = 100.00,
        last_month_rent: monthly_rent, 
        security_deposit: 250.00,
    ))    
    user_count = user_count + 1
end

#make a few terminated leases
user_count = 0
for for_property in properties do
    lease_type_count = rand(LeaseType.all.count)
    lease_type_random = LeaseType.offset(lease_type_count).first
    start_date = rand_past_date(rand(1000), lease_type_random.duration_months)
    end_date = start_date >> lease_type_random.duration_months
    monthly_rent = monthly_price_options[rand(monthly_price_options.count)]
    Lease.create(
            user_id: temp_users[user_count].id,
            lease_type_id: lease_type_random.id,
            status: false,
            monthly_rent_price: monthly_rent,
            balance: 0.0,
            property_address_id: for_property.id,
            start_date: start_date,
            end_date: end_date,
            first_month_rent: monthly_rent = 100.00,
            last_month_rent: monthly_rent, 
            security_deposit: 250.00,
        )
end


#apply monthly rent charge to active leases
admin = User.all[0]
applied_rent = []
active_leases = admin.admin_get_all_active_leases()
for active_lease in active_leases do    
    random_times = rand(1..10)
    applied_rent.push(random_times)
    for i in 1..random_times do
        active_lease.balance = active_lease.balance + active_lease.monthly_rent_price
        active_lease.save()        
    end
end

#byebug

#make payments
indexer = 0
for active_lease in active_leases do
    for i in 1..applied_rent[indexer] do
        sleep 0.5
        payment = Payment.create(lease_id: active_lease.id, amount: active_lease.monthly_rent_price)
        admin.apply_payment_to_lease(active_lease, payment)
    end
    indexer = indexer + 1
    # random_times = rand(10)
    # for i in 0..random_times do
    # for i in applied_rent
    #     for j in 1..i    
    #         sleep 0.5
    #         payment = Payment.create(lease_id: active_lease.id, amount: active_lease.monthly_rent_price)
    #         admin.apply_payment_to_lease(active_lease, payment)
    #     end
    # end
end


puts "Seeding Complete!"


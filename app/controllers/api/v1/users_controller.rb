class Api::V1::UsersController < ApplicationController
    skip_before_action :authorized, only: [:create]
   
    def profile
      render json: { user: UserSerializer.new(current_user) }, status: :accepted
    end

    def show
      if(!@user.admin)
        return render json: {statusmessage: "Fail-admin_create_property-#{@user.username} is not admin"}        
      end
      
      found_user = User.find(params[:id])
      if(!found_user)
        return render json: {status: 400, statusmessage: "Bad Request. User with id #{@fail_id} not found."}
      end
      
      user_contact = {}
      user_contacts = UserContact.where(user_id: found_user.id, address_type: "PRIOR")
      if(user_contacts.count > 0)
        user_contact = user_contacts[0]
      end
      
      render json: { status: 200, statusmessage: "Retrieved User", user: UserSerializer.new(found_user), user_contact: user_contact }, status: :accepted
    end
   
    def create      
      @user = User.create(user_params)
      if @user.valid?
        @token = encode_token({ user_id: @user.id })
        render json: { status: 200, statusmessage: "User created", user: UserSerializer.new(@user), jwt: @token }, status: :created
      else
        render json: { status: 400, statusmessage: 'Failed to create user' }, status: :not_acceptable
      end
    end

    def validate_params(params, parameter)
      params[parameter].each do 
        |id, value| 
        if value.blank?
          @fail_id = id
          return false
        end            
      end
      return true
    end

    def admin_create_property  
      if(!@user.admin)
        return render json: {statusmessage: "Fail-admin_create_property-#{@user.username} is not admin"}        
      end

      # check properties
      if !validate_params(params, "property")
        return render json: {status: 400, statusmessage: "Bad Request. Required parameters #{@fail_id} must not be empty."}
      end
      
      createdProperty = PropertyAddress.create(
        street_address: params["property"]["streetAddress"],
        apartment: params["property"]["apartment"],          
        city: params["property"]["city"],
        state: params["property"]["state"],
        zip: params["property"]["zip"]
      )
      if createdProperty.valid?
        render json: {statusmessage: "Created PropertyAddress.", createdProperty: createdProperty}, status: :created
      else
        render json: {statusmessage: "Failed to create property_address."}
      end        
    end

    def admin_create_lease
      #byebug
      if(!@user.admin)
        return render json: {statusmessage: "Fail-admin_create_lease-#{@user.username} is not admin"}        
      end
      #byebug
      if !validate_params(params, "leaseToCreate")
        return render json: {status: 400, statusmessage: "Bad Request-admin_create_lease. Required parameter #{@fail_id} must not be empty."}
      end       
            
      #byebug
      foundLeaseType = LeaseType.find_by_id(params["leaseToCreate"]["lease_type_id"])      
      if !foundLeaseType                 
        return render json: {status: 404, statusmessage: "Bad Request-admin_create_lease. Id LeaseType Id#{params["leaseToCreate"]["lease_type_id"]} was not found."}
      end
      #byebug
      propertyForNewLease = PropertyAddress.find_by_id(params["leaseToCreate"]["property_id"])      
      if !propertyForNewLease      
        return render json: {status: 404, statusmessage: "Bad Request-admin_create_lease. PropertyAddress Id#{params["leaseToCreate"]["property_id"]} was not found."}
      end
      #byebug
      renterForNewLease = User.find_by_id(params["leaseToCreate"]["user_id"])      
      if !renterForNewLease      
        return render json: {status: 404, statusmessage: "Bad Request-admin_create_lease. User Id#{params["leaseToCreate"]["user_id"]} was not found."}
      end
      #byebug
      random_start_date = @user.rand_future_date(90)
      random_end_date = random_start_date >> foundLeaseType.duration_months
      #byebug
      createdLease = Lease.create(
        user_id: params["leaseToCreate"]["user_id"],        
        property_address_id: params["leaseToCreate"]["property_id"],
        lease_type_id: params["leaseToCreate"]["lease_type_id"],          
        monthly_rent_price: params["leaseToCreate"]["monthly_rent_price"],
        start_date: random_start_date, # params["leaseToCreate"]["start_date"],
        end_date: random_end_date, # params["leaseToCreate"]["end_date"],
        first_month_rent: params["leaseToCreate"]["first_month_rent"],
        last_month_rent: params["leaseToCreate"]["last_month_rent"],
        security_deposit: params["leaseToCreate"]["security_deposit"],
        balance: params["leaseToCreate"]["balance"],
        status: true
      )
      if createdLease.valid?
        render json: {status: 200, statusmessage: "Successfully created lease with id #{createdLease.id}", foundLeaseType: foundLeaseType}, status: :created
      else
        render json: {status: 500, statusmessage: "Failed to create lease."}
      end    
       
    end

    def admin_charge_monthly_rents_active_leases
      if(!@user.admin)
        return render json: {statusmessage: "Fail-admin_create_payment-#{@user.username} is not admin"}        
      end

      active_leases = @user.admin_get_all_active_leases()
      for active_lease in active_leases do    
        active_lease.balance = active_lease.balance + active_lease.monthly_rent_price
        active_lease.save()
      end
    end

    def comment_subset

      last_comment = Comment.all.last
      latest_time_stamp = ""
      if(last_comment)
        latest_time_stamp = last_comment.created_at
      end

      param_latest_time_stamp = Time.zone.parse(params["comments_query_params"]["latest_time_stamp"])
      
      if(param_latest_time_stamp.to_s === latest_time_stamp.to_s)
        return render json: {status: 304, latest_time_stamp: latest_time_stamp, statusmessage: "No updates"}  
      end

      month = params["comments_query_params"]["month"]
      month= month +1
      year = params["comments_query_params"]["year"]      
      
      mapped_comments = Comment.all.map{|com|  {id: com.id, user_id: com.user.id, firstname: com.user.firstname, lastname: com.user.lastname, date: com.created_at, month: com.created_at.month, year: com.created_at.year,comment: com.comment}}      
      
      filtered_mapped_comments = mapped_comments.select{|item| item[:month] == month && item[:year] == year}
      
      #comments = Comment.all

      return render json: {status: 200, latest_time_stamp: latest_time_stamp, comments: filtered_mapped_comments, statusmessage: "Retrieved comments"}
    end

    def create_comment      
      created_comment = Comment.create(user_id: @user.id, comment: params["comment"])      
      if(!created_comment)
        return render json: {status: 400, statusmessage: "Fail-create_comment-#{@user.username} was unsuccessful"}        
      end
      return render json: {status: 201, statusmessage: "Success. Created comment with id=#{created_comment.id}."}, status: :created
    end

    def admin_create_payment
      if(!@user.admin)
        return render json: {statusmessage: "Fail-admin_create_payment-#{@user.username} is not admin"}        
      end
      
      if !validate_params(params, "payment")
        return render json: {status: 400, statusmessage: "Bad Request-admin_create_payment. Required parameter #{@fail_id} must not be empty."}
      end    
      foundLease = Lease.find(params["payment"]["lease_id"])      
      if foundLease
        
        createdPayment = Payment.create(
          lease_id: foundLease.id,
          amount: BigDecimal(params["payment"]["amount"])                        
        )
        if createdPayment.valid?
          render json: {statusmessage: "Created Payment.", createdPayment: createdPayment}, status: :created
        else
          render json: {statusmessage: "Failed to create payment."}
        end  
      else
        render json: {statusmessage: "Invalid lease submited"}
      end
    end

    def renter_create_payment    
      if !validate_params(params, "payment")
        return render json: {status: 400, statusmessage: "Bad Request-admin_create_payment. Required parameter #{@fail_id} must not be empty."}
      end    
      foundLease = Lease.find(params["payment"]["lease_id"])      
      if foundLease
        
        createdPayment = Payment.create(
          lease_id: foundLease.id,
          amount: BigDecimal(params["payment"]["amount"])                        
        )
        if createdPayment.valid?
          @user.apply_payment_to_lease(foundLease, createdPayment)  # This call needs refactoring for security
          render json: {status: 201, statusmessage: "Created Payment.", createdPayment: createdPayment}, status: :created
        else
          return render json: {status: 404, statusmessage: "Failed to create payment."}          
        end  
      else
        render json: {status: 400, statusmessage: "Invalid lease submited"}
      end
    end

    def admin_get_all_users
      if(!@user.admin)
        return render json: {statusmessage: "Fail-admin_get_all_users-#{@user.username} is not admin"}
      end     
      render json: {statusmessage: "Success-admin_get_all_users", users: User.all}              
    end

    def admin_get_all_lease_types
      if(!@user.admin)
        return render json: {statusmessage: "Fail-admin_get_all_lease_types-#{@user.username} is not admin"}
      end      
      render json: {statusmessage: "Success-admin_get_all_lease_types", lease_types: LeaseType.all}      
    end

    def admin_get_all_leases      
      if(!@user.admin)
        return render json: {statusmessage: "Fail-admin_get_all_leases-#{@user.username} is not admin"}
      end        
      render json: {statusmessage: "Success-admin_get_all_leases", leases: Lease.all}      
    end

    def admin_get_all_active_leases      
      if(!@user.admin)
        return render json: {statusmessage: "Fail-admin_get_all_leases-#{@user.username} is not admin"}
      end            
      render json: {statusmessage: "Success-admin_get_all_active_leases", activeLeases: @user.admin_get_all_active_leases()}              
    end
    
    def admin_get_all_terminated_leases      
      if(!@user.admin)
        return render json: {statusmessage: "Fail-admin_get_all_leases-#{@user.username} is not admin"}
      end         
      return render json: {statusmessage: "Success-admin_get_all_terminated_leases", terminatedLeases: @user.admin_get_all_terminated_leases()}              
    end

    def admin_get_all_properties      
      if(!@user.admin)
        return render json: {statusmessage: "Fail-admin_get_all_leases-#{@user.username} is not admin"}
      end      
      render json: {statusmessage: "Success-admin_get_all_properties", properties: PropertyAddress.all}              
    end

    def admin_get_all_payments
      if(!@user.admin)
        return render json: {statusmessage: "Fail-admin_get_all_payments-#{@user.username} is not admin"}
      end      
      render json: {statusmessage: "Success-admin_get_all_payments", payments: Payment.all}              
    end

    def admin_terminate_lease
      if(!@user.admin)
        return render json: {statusmessage: "Fail-admin_terminate_lease-#{@user.username} is not admin"}
      end 

      if !validate_params(params, "leaseToTerminate")
        return render json: {status: 400, statusmessage: "Bad Request. Required parameter #{@fail_id} must not be empty."}
      end           
      foundLease = Lease.find(params["leaseToTerminate"]["lease_id"])      
      if foundLease
        foundLease.update(status: false)
        return render json: {statusmessage: "Success. Lease with id=#{params["leaseToTerminate"]["lease_id"]} was terminated."}
      else
        return render json: {status: 404, statusmessage: "Bad Request. Lease with id=#{id} was not found."}
      end
    end

    def admin_apply_payment_to_lease
      if(!@user.admin)
        return render json: {statusmessage: "Fail-admin_apply_payment_to_lease-#{@user.username} is not admin"}
      end 

      if !validate_params(params, "leaseToAddPaymentTo")
        return render json: {status: 400, statusmessage: "Bad Request-admin_apply_payment_to_lease. Required parameter #{@fail_id} must not be empty."}
      end       
                            
      foundLease = Lease.find_by_id(params["leaseToAddPaymentTo"]["lease_id"])      
      if !foundLease                 
        return render json: {status: 404, statusmessage: "Bad Request-admin_apply_payment_to_lease. Id Lease Id#{params["leaseToAddPaymentTo"]["lease_id"]} was not found."}
      end

      paymentForLease = Payment.find_by_id(params["leaseToAddPaymentTo"]["payment_id"])      
      if !paymentForLease      
        return render json: {status: 404, statusmessage: "Bad Request-admin_apply_payment_to_lease. Payment Id#{params["leaseToAddPaymentTo"]["payment_id"]} was not found."}
      end
      
      foundLease.update(balance: (foundLease.balance - paymentForLease.amount))
      return render json: {statusmessage: "Success. Payment with id#{paymentForLease.id} of $#{paymentForLease.amount.to_digits()} was made to lease with id=#{foundLease.id} was terminated."}
      
    end

    def admin_manually_apply_monthly_rent_to_active_leases
      leases = Lease.where(status: true)
      
      leases.each do |lease| 
        lease.update(balance: lease.balance + lease.monthly_rent_price)
      end
      return render json: {statusmessage: "Success. Lease balances have been each charged their monthly rent"}
    end

    def admin_update_profile
      if(!@user.admin)
        return render json: {statusmessage: "Fail-admin_apply_payment_to_lease-#{@user.username} is not admin"}
      end 

      user_contact = {}
      user_contacts = UserContact.where(user_id: params["updated_profile_data"]["id"], address_type: "PRIOR")
      user_to_update = User.find(params["updated_profile_data"]["id"]);
      if(user_contacts.count == 0)
        user_contact = UserContact.create(
            street_address: "",
            city: "",
            state: "",
            zip: "",
            phone: "",
            email: "",
            user_id: current_user.id,
            address_type: "PRIOR"    
        )        
      else
        user_contact = user_contacts[0]
      end
      
      if(!user_contact)
        return render json: {status: 400, statusmessage: "Bad Request-update_profile. Unable to get or create a user_contact to update"}
      end      
      user_contact.update(email: params["updated_profile_data"]["email"], phone: params["updated_profile_data"]["phone"])            

      if(!user_to_update)
        return render json: {status: 400, statusmessage: "Bad Request-update_profile. Unable to find user with id #{params["updated_profile_data"]["id"]}"}
      end
      user_to_update.update(firstname: params["updated_profile_data"]["first_name"], lastname: params["updated_profile_data"]["last_name"])
    
      render json: { status: 204, statusmessage: "Updated user profile information", user: UserSerializer.new(user_to_update), user_contact: user_contact }, status: :accepted      
    end


    def update_profile
      
      user_contact = {}
      user_contacts = UserContact.where(user_id: current_user.id, address_type: "PRIOR")
      
      if(user_contacts.count == 0)
        user_contact = UserContact.create(
            street_address: "",
            city: "",
            state: "",
            zip: "",
            phone: "",
            email: "",
            user_id: current_user.id,
            address_type: "PRIOR"    
        )        
      else
        user_contact = user_contacts[0]
      end
      
      if(!user_contact)
        return render json: {status: 400, statusmessage: "Bad Request-update_profile. Unable to get or create a user_contact to update"}
      end      
      user_contact.update(email: params["updated_profile_data"]["email"], phone: params["updated_profile_data"]["phone"])            
      current_user.update(firstname: params["updated_profile_data"]["first_name"], lastname: params["updated_profile_data"]["last_name"])
    
      render json: { status: 204, statusmessage: "Updated user profile information", user: UserSerializer.new(current_user), user_contact: user_contact }, status: :accepted      
    end

    def profile_detail      
      user_contacts = UserContact.where(user_id: current_user.id, address_type: "PRIOR")
      render json: { user: UserSerializer.new(current_user), user_contact: user_contacts[0] }, status: :accepted
    end

    def renter_get_lease      
      primary_leases = Lease.where(user_id: current_user.id, status: true)      
      user_on_lease = {}      
      property_on_lease = {}
      if(primary_leases.count > 0)        
        user_on_lease = User.find(primary_leases[0].user_id)
        property_on_lease = PropertyAddress.find(primary_leases[0].property_address_id)
        primary_lease = primary_leases[0]
      end       
      render json: { status: 200, primary_lease: primary_lease, user_on_lease: user_on_lease, property_on_lease: property_on_lease}, status: :accepted
    end

    def renter_get_payment_history
      primary_lease = Lease.where(user_id: current_user.id, status: true)
      if primary_lease.count > 0
        payment_history = Payment.where(lease_id: primary_lease[0].id)    
        return render json: { payment_history: payment_history}, status: :accepted
      end
      return render json: { payment_history: []}, status: :accepted
    end

    def admin_get_payment_history_for_renter
      primary_lease = Lease.where(user_id: params["user_id"], status: true)
      if primary_lease.count > 0
        payment_history = Payment.where(lease_id: primary_lease[0].id)         
        return render json: { payment_history: payment_history}, status: :accepted
      end
      return render json: { payment_history: []}, status: :accepted
    end
    

    private   
    def user_params
      params.require(:user).permit(:username, :password, :firstname, :lastname, :admin)
    end
end
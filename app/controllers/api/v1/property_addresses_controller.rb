class Api::V1::PropertyAddressesController < ApplicationController
    skip_before_action :authorized, only: [:create]

    def show
        #byebug
        if(!@user.admin)
          return render json: {info: "Fail-admin_create_property-#{@user.username} is not admin"}        
        end
        
        found_property_address = PropertyAddress.find(params[:id])
        if(!found_property_address)
          return render json: {status: 400, info: "Bad Request. PropertyAddress with id #{params[:id]} not found."}
        end

        render json: { status: 200, property_address: found_property_address}, status: :accepted

      end

      def update_property_address
        #byebug
        found_property_address = {}
        query_id = params["updated_property_address_data"][:id]
        found_property_address = PropertyAddress.find(query_id)
        
        if(!found_property_address)
            return render json: {status: 400, statusmessage: "Bad Request. update_property_address with id #{query_id} not found."}            
        end      
        found_property_address.update(
            street_address: params["updated_property_address_data"]["street_address"],
            apartment: params["updated_property_address_data"]["apartment"],
            zip: params["updated_property_address_data"]["zip"],
            city: params["updated_property_address_data"]["city"],
            state: params["updated_property_address_data"]["state"])
        
        found_property_address = PropertyAddress.find(query_id)   

        render json: { status: 204, statusmessage: "Updated property address information", property_address:found_property_address }, status: :accepted      
      end

end

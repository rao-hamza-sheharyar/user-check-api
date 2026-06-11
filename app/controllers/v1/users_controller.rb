module V1
  class UsersController < ApplicationController
    def check_status
      ban_status = UserCheckStatusService.new(
        idfa: params[:idfa],
        rooted_device: params[:rooted_device],
        ip: request.headers["CF-Connecting-IP"] || request.remote_ip,
        country: request.headers["CF-IPCountry"]
      ).call

      render json: { ban_status: ban_status }
    end
  end
end

class RegionsController < ApplicationController
  def get_regions
    @regions = Region.all_regions
    render :json => @regions.to_json
  end
end

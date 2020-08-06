class PhotosController < ApplicationController

  def create
    @bouncehouse = Bouncehouse.find(params[:bouncehouse_id])

    if params[:images]
        params[:images].each do |img|
        @bouncehouse.photos.create(image: img)
      end

      @photos = @bouncehouse.photos
      redirect_back(fallback_location: request.referer, notice: "Saved...")
    end
  end

  def destroy
    @photo = Photo.find(params[:id])
    @bouncehouse = @photo.bouncehouse

    @photo.destroy
    @photos = Photo.where(bouncehouse_id: @bouncehouse.id)

    respond_to :js
  end
end

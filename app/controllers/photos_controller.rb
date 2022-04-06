class PhotosController < ApplicationController

  def create
    @rug = Rug.find(params[:rug_id])

    if params[:images]
        params[:images].each do |img|
        @rug.photos.create(image: img)
      end

      @photos = @rug.photos
      redirect_back(fallback_location: request.referer, notice: "Saved...")
    end
  end

  def destroy
    @photo = Photo.find(params[:id])
    @rug = @photo.rug

    @photo.destroy
    @photos = Photo.where(rug_id: @rug.id)

    respond_to :js
  end
end

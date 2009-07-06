class StylesheetsController < ApplicationController
  def application
    respond_to do |format|
      format.css do
        render :action => params[:id]
      end
    end
  end
end


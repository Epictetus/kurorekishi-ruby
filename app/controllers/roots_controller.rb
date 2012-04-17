# -*- encoding: utf-8 -*-

class RootsController < ApplicationController
  ############################################################################

  before_filter do
    if queued? then redirect_to(cleaner_path); return end
    if authorized? then redirect_to(new_cleaner_path); return end
  end

  ############################################################################

  def show
    respond_to do |format|
      format.html
    end
  end

end

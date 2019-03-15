class ElectronicFilesController < ApplicationController
  def new
    @file = ElectronicFile.new
    
  end
end

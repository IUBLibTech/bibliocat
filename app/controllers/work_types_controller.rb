class WorkTypesController < ApplicationController
  before_action :set_work_type, only: [:show, :edit, :update, :destroy]

  # GET /work_types
  # GET /work_types.json
  def index
    @work_types = WorkType.all
  end

  # GET /work_types/1
  # GET /work_types/1.json
  def show
  end

  # GET /work_types/new
  def new
    @work_type = WorkType.new
  end

  # GET /work_types/1/edit
  def edit
  end

  # POST /work_types
  # POST /work_types.json
  def create
    @work_type = WorkType.new(work_type_params)

    respond_to do |format|
      if @work_type.save
        format.html { redirect_to @work_type, notice: 'Work type was successfully created.' }
        format.json { render :show, status: :created, location: @work_type }
      else
        format.html { render :new }
        format.json { render json: @work_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /work_types/1
  # PATCH/PUT /work_types/1.json
  def update
    respond_to do |format|
      if @work_type.update(work_type_params)
        activate_schema
        format.html { redirect_to @work_type, notice: 'Work type was successfully updated.' }
        format.json { render :show, status: :ok, location: @work_type }
      else
        format.html { render :edit }
        format.json { render json: @work_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /work_types/1
  # DELETE /work_types/1.json
  def destroy
    @work_type.destroy
    respond_to do |format|
      format.html { redirect_to work_types_url, notice: 'Work type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_work_type
      @work_type = WorkType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def work_type_params
      params.require(:work_type).permit(:registered_name, :display_name, :is_type_of, :schema_file)
    end

    def activate_schema
      if @work_type.schema_datastream
        schema_file = @work_type.schema_datastream
        file_name = @work_type.registered_name.underscore + '.yml'
        begin
          puts "Updating the schema file in config/work_types/#{file_name} from Work Type in Fedora"
          File.open(Rails.root + "config/work_types/" + file_name, "w+b") {|f| f.write(schema_file.read)}
        rescue
          puts "Unable to write new config to config/work_types/#{file_name}"
        end
      end
    end

end

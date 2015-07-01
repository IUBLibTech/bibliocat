describe WorkTypesController do
  render_views

  let!(:test_work_type) { FactoryGirl.create :work_type }

  describe '#index' do
    before(:each) { get :index }
    it 'sets @work_types' do
      expect(assigns(:work_types)).to eq [test_work_type]
    end
    it 'renders :index template' do
      expect(response).to render_template :index
    end
  end

  describe '#show' do
    before(:each) { get :show, id: test_work_type.pid }
    it 'sets @work_type' do
      expect(assigns(:work_type)).to eq test_work_type
    end
    it 'renders :show template' do
      expect(response).to render_template :show
    end
  end

  describe '#new' do
    before(:each) { get :new }
    it 'sets @work_type' do
      expect(assigns(:work_type)).to be_a_new WorkType
      expect(assigns(:work_type)).not_to be_persisted
    end
    it 'renders :new template' do
      expect(response).to render_template :new
    end
  end

  describe '#edit' do
    before(:each) { get :edit, id: test_work_type.pid }
    it 'sets @work_type' do
      expect(assigns(:work_type)).to eq test_work_type
    end
    it 'renders :edit template' do
      expect(response).to render_template :edit
    end
  end

  describe '#create' do
    context 'with valid params' do
      shared_examples "creates a work_type" do |parent|
        it 'assigns @work_type' do
          post_create
          expect(assigns(:work_type)).to be_a WorkType
          expect(assigns(:work_type)).to be_persisted
        end
        it 'saves the new object' do
          expect{ post_create }.to change(WorkType, :count).by(1)
        end
        if parent
          it 'redirects to the parent work_typed' do
            post_create
            expect(response).to redirect_to test_work_typed
          end
      	else
          it 'redirects to the work_type' do
            post_create
            expect(response).to redirect_to assigns(:work_type)
          end
        end
      end
      context 'with a parent' do
        let(:post_create) { post :create, work_type: FactoryGirl.attributes_for(:work_type, parent: test_work_typed.pid) }
        include_examples "creates a work_type", true
      end
      context 'without a parent' do
        let(:post_create) { post :create, work_type: FactoryGirl.attributes_for(:work_type) }
        include_examples "creates a work_type", false 
      end
    end
    context 'with invalid params' do
      before(:each) do
        first_work_type = FactoryGirl.create :work_type, parent: test_work_typed.pid
        test_work_typed.reload
        post :create, work_type: FactoryGirl.attributes_for(:work_type, parent: test_work_typed.pid)
      end
      it 'renders the new template' do
        expect(response).to render_template(:new)
      end
    end
  end

  describe '#update' do
    let(:updated_number) { test_work_type.logical_number + " updated" }
    context 'with valid params' do
      let(:put_update) { put :update, id: test_work_type.id, work_type: { logical_number: updated_number } }
      shared_examples 'successful update' do
        it 'assigns @work_type' do
          expect(assigns(:work_type)).to eq test_work_type
        end
        it 'updates values' do
          expect(test_work_type.logical_number).not_to eq updated_number
          test_work_type.reload
          expect(test_work_type.logical_number).to eq updated_number
        end
        it 'flashes success' do
          expect(flash[:notice]).to match(/success/i)
        end
      end
      context 'when came from work_typed' do
        before(:each) { session[:came_from] = :work_typed }
        context 'with parent work_typed' do
          before(:each) do
            test_work_type.parent = test_work_typed.pid
            test_work_type.save!
            put_update
          end
          it 'redirects to parent work_typed' do
            expect(response).to redirect_to work_typed_path(test_work_typed.pid)
          end
          include_examples 'successful update'
        end
        context 'without a parent work_typed' do
          before(:each) do
            test_work_type.parent = nil
            test_work_type.save!
            put_update
          end
          it 'redirects to work_typed_url' do
            expect(response).to redirect_to work_typeds_path
          end
          include_examples 'successful update'
        end
      end
      context 'when not coming from work_typed' do
        before(:each) do
          session[:came_from] = nil
          put_update
        end
        it 'redirects to the work_type' do
          expect(response).to redirect_to test_work_type
        end
        include_examples 'successful update' 
      end
    end
    context 'with invalid params' do
      before(:each) do
        put :update, id: test_work_type.pid, work_type: { logical_number: updated_number, prev_sib: other_work_type.pid }
      end
      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#destroy' do
    let(:delete_destroy) { delete :destroy, id: test_work_type.pid }
    it 'destroys a WorkType' do
      expect{ delete_destroy }.to change(WorkType, :count).by(-1)
    end
    it 'redirects to work_types index' do
      delete_destroy
      expect(response).to redirect_to work_types_path
    end
  end

end

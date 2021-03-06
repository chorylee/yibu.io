require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe TopicsController, type: :controller do

  let(:user) {
    create :user
  }

  let(:tag) {
    create :tag
  }

  # This should return the minimal set of attributes required to create a valid
  # Topic. As you add validations to Topic, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {title: 'First topic', content: 'Hello World! this is first topic!', format: 'text', tag_id: tag.id}
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # TopicsController. Be sure to keep this updated too.
  let(:valid_session) {{}}

  describe "GET #index" do
    context "topics sort by score" do
      it 'few positive-vote only posts should not be top' do
        # 6 up-votes, 1 down-vote
        reliable_topic = create :topic
        5.times {create(:user).up_vote reliable_topic}
        create(:user).down_vote reliable_topic
        reliable_topic.refresh_score
        # only 2 up-votes
        few_votes_topic = create :topic
        create(:user).up_vote few_votes_topic
        few_votes_topic.refresh_score

        get :index

        topics = assigns(:topics)
        expect(topics.to_a.index(reliable_topic)).to be < topics.to_a.index(few_votes_topic)
      end

      it 'positive-votes percent should better than count' do
        # 4 up-votes, 1 down-vote, 3 more up votes, 80% positive
        more_percent_ups_topic = create :topic
        3.times {create(:user).up_vote more_percent_ups_topic}
        create(:user).down_vote more_percent_ups_topic
        more_percent_ups_topic.refresh_score
        # 10 up-votes, 5 down-votes, 5 more up votes, 66% positive
        more_ups_topic = create :topic
        9.times {create(:user).up_vote more_ups_topic}
        5.times {create(:user).down_vote more_ups_topic}
        more_ups_topic.refresh_score

        get :index

        topics = assigns(:topics)
        expect(topics.to_a.index(more_percent_ups_topic)).to be < topics.to_a.index(more_ups_topic)
      end

      it 'new posts should better than old' do
        new_topic = create :topic
        new_topic.refresh_score

        old_topic = create :topic, created_at: 2.days.ago
        old_topic.refresh_score

        get :index

        topics = assigns(:topics)
        expect(topics.to_a.index(new_topic)).to be < topics.to_a.index(old_topic)
      end
    end
  end

  describe "GET #show" do
    it "assigns the requested topic as @topic" do
      topic = user.topics.create! valid_attributes
      get :show, params: {id: topic.to_param}
      expect(assigns(:topic)).to eq(topic)
    end
  end

  describe "GET #new" do
    it "assigns a new topic as @topic" do
      sign_in user
      get :new, params: {}
      expect(assigns(:topic)).to be_a_new(Topic)
    end

    it "non sign in user cannot see this page" do
      get :new, params: {}
      expect(assigns(:topic)).to be_nil
    end
  end

  describe "GET #edit" do
    it "assigns the requested topic as @topic" do
      sign_in user
      topic = user.topics.create! valid_attributes
      expect {
        get :edit, params: {id: topic.to_param}
      }.to raise_exception(ActionController::UrlGenerationError)
    end

    it "other user cannot edit @topic" do
      sign_in create(:user)
      topic = user.topics.create! valid_attributes
      expect {
        get :edit, params: {id: topic.to_param}
      }.to raise_exception(ActionController::UrlGenerationError)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      before(:each) {
        sign_in user
      }
      it "creates a new Topic" do
        expect {
          post :create, params: {topic: valid_attributes}
        }.to change(Topic, :count).by(1)
      end

      it "assigns a newly created topic as @topic" do
        post :create, params: {topic: valid_attributes}
        expect(assigns(:topic)).to be_a(Topic)
        expect(assigns(:topic)).to be_persisted
      end

      it "redirects to the created topic" do
        post :create, params: {topic: valid_attributes}
        expect(response).to redirect_to(Topic.last)
      end
    end

    context "with invalid params" do
      it "non sign in user can not create post" do
        post :create, params: {topic: valid_attributes}
        expect(assigns(:topic)).to be_nil
      end

      it "re-renders the 'new' template" do
        sign_in user
        post :create, params: {topic: {content: 'should not pass'}}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {title: 'It will be cool!'}
      }

      before(:each) {
        sign_in user
      }

      it "updates the requested topic" do
        topic = user.topics.create! valid_attributes
        expect {
          put :update, params: {id: topic.to_param, topic: new_attributes}
        }.to raise_exception(ActionController::UrlGenerationError)
      end
    end

    context "with invalid params" do
      let(:invalid_attributes) {{title: ''}}
      it "assigns the topic as @topic" do
        sign_in user
        topic = user.topics.create! valid_attributes
        expect {
          put :update, params: {id: topic.to_param, topic: invalid_attributes}
        }.to raise_exception(ActionController::UrlGenerationError)
      end

      it "user not sign in" do
        topic = user.topics.create! valid_attributes
        expect {
          put :update, params: {id: topic.to_param, topic: invalid_attributes}
        }.to raise_exception(ActionController::UrlGenerationError)
      end

      it "re-renders the 'edit' template" do
        sign_in user
        topic = user.topics.create! valid_attributes
        expect {
          put :update, params: {id: topic.to_param, topic: invalid_attributes}
        }.to raise_exception(ActionController::UrlGenerationError)
      end
    end
  end

  # describe "DELETE #destroy" do
  #   before :each do
  #     sign_in user
  #   end
  #
  #   it "destroys the requested topic" do
  #     topic = user.topics.create! valid_attributes
  #     expect {
  #       delete :destroy, params: {id: topic.to_param}
  #     }.to change(Topic, :count).by(-1)
  #   end
  #
  #   it "redirects to the topics list" do
  #     topic = user.topics.create! valid_attributes
  #     delete :destroy, params: {id: topic.to_param}
  #     expect(response).to redirect_to(topics_url)
  #   end
  # end

  describe "vote posts" do
    let(:topic) {create :topic}
    it 'upvote a post' do
      topic # preload
      expect {
        sign_in create(:user)
        post :up_vote, params: {id: topic.to_param}
      }.to change(topic, :votes_count).by(1)
    end


    it "POST #down_vote" do
      topic # preload
      expect {
        sign_in create(:user)
        post :down_vote, params: {id: topic.to_param}
      }.to change(topic, :votes_count).by(-1)
    end

    it "DELETE #unvote" do
      topic # preload
      expect {
        sign_in create(:user)
        delete :unvote, params: {id: topic.to_param}
      }.to change(topic, :votes_count).by(0)
    end
  end
end

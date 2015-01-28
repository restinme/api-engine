require_relative '../spec_helper'

module RestInMe
  RSpec.describe 'listing an entity collection' do
    include ::Rack::Test::Methods

    let(:ultra_pod) { create :app, :with_config }

    context 'for another app' do
      let(:new_app) { create :app }

      before do
        set_auth_headers_for!(new_app, 'GET', {})
        get '/api/podcasts'
      end

      it do
        expect(last_response.status).to eql 404
        expect(last_json.errors).to eql ['Not Found']
      end
    end

    describe 'for the current app' do
      context 'with existing entries' do
        before do
          10.times do |index|
            params = { name: "NerdCast-#{index}" }
            set_auth_headers_for!(ultra_pod, 'POST', params)
            post '/api/podcasts', params
          end
          set_auth_headers_for!(ultra_pod, 'GET', {})
          get '/api/podcasts'
        end

        it 'should contain all defined fields' do
          expect(last_response.status).to eql 200
          expect(last_json['count']).to eql 10

          #p last_response.body
          last_json.items.each_with_index do |item, index|
            expect(last_json.items[index].keys)
              .to match_array %w(id name created_at updated_at)
            expect(last_json.items[index].name).to eql "NerdCast-#{index}"
          end
        end
      end

      context 'without entries' do
        before do
          set_auth_headers_for!(ultra_pod, 'GET', {})
          get '/api/podcasts'
        end

        it do
          expect(last_response.status).to eql 200
          expect(last_json['count']).to eql 0
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe "ChatsV1s", type: :request do
	context '#index' do
		let!(:url) { '/api/v1/chats' }

		context 'When there are no chats' do 
			let!(:expected_response){{data: []}}

			it 'should return an empty array' do
				get url 
				expect(response.status).to eq 200
				expect(JSON.parse(response.body)['data']).to eq expected_response[:data]
			end
		end
		context 'When there are some chats created' do
			before do
				App.create(name: "App1", token:"a1234")
				App.create(name: "App2", token:"b1234")
				Chat.create(app_token: "a1234", number:1)
				Chat.create(app_token: "a1234", number:2)
				Chat.create(app_token: "b1234", number:1)
			end

			let!(:expected_response) do
				JSON.parse(File.read("#{Rails.root}/spec/fixtures/chats/chat_data.json"))
			end

			it 'should return an array of all created records' do
				get url
				expect(response.status).to eq 200
				expect(response.body).to eq expected_response.to_json
			end
		end
	end

	context '#show' do
		let!(:id) { "b1234" }
		let!(:url) { "/api/v1/applications/#{id}/chats" }
		context 'When requesting chats of non valid token' do 
			let!(:expected_response){"No App Found"}
			before do
				App.create(name: "App1", token:"a1234")
			end

			it 'should return an app not found' do
				get url 
				expect(response.status).to eq 404
				expect(JSON.parse(response.body)['data']).to eq expected_response
			end
		end
		context 'When requesting a valid token with no chats' do
			before do
				App.create(name: "App1", token:"b1234")
			end
			it 'should return empty list of chats' do
				get url
				expect(response.status).to eq 200
				expect(JSON.parse(response.body)['data']).to eq []
			end
		end
		context 'When requesting a valid token with created chats' do
			let!(:expected_response) do
				JSON.parse(File.read("#{Rails.root}/spec/fixtures/chats/chat_data_show.json"))
			end
			before do
				App.create(name: "App2", token:"b1234")
				Chat.create(app_token: "b1234", number:1)
				Chat.create(app_token: "b1234", number:2)
			end				
			it 'should return correct data of created chats' do
				get url
				expect(response.status).to eq 200
				expect(response.body).to eq expected_response.to_json
			end
		end
	end

	context '#create' do
		context 'When creating with non valid token' do 
			let!(:token) { "b1234" }
			let!(:url) { "/api/v1/applications/#{token}/chats" }
			before do
				App.create(name: "App1", token:"a1234")
			end	
			it 'should return app not found response' do
				post url
				expect(response.status).to eq 404
				expect(JSON.parse(response.body)['data']).to eq "No App Found"
			end
			it 'should not change the count' do
				post url
				expect( Chat.count).to eq 0
			end
		end

		context 'When creating with valid token' do
			before do
				post '/api/v1/applications', params: {app: {name: "random name"}}
			end
			it 'should return correct value of created chat' do  
				post "/api/v1/applications/#{App.first.token}/chats"
				expect(response.status).to eq 200
				expect(JSON.parse(response.body)['data']['app_token']).to eq App.first.token
				expect(JSON.parse(response.body)['data']['number']).to eq 1
				expect(JSON.parse(response.body)['data']['messages_count']).to eq 0
			end
			it 'should enqueue a job in the chats creator queue' do
				expect { post "/api/v1/applications/#{App.first.token}/chats" }.to change(
				  Sidekiq::Queues['chats-creator'], :size
				).by(1)
			end			
		end

		context 'When creating multiple chats for same app' do
			before do
				post '/api/v1/applications', params: {app: {name: "random name"}}
			end
			it 'should create the chats with incremental chat number' do  
				post "/api/v1/applications/#{App.first.token}/chats"
				post "/api/v1/applications/#{App.first.token}/chats"
				expect(response.status).to eq 200
				expect(JSON.parse(response.body)['data']['number']).to eq 2
			end
		end
	end
end

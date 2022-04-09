require 'rails_helper'

RSpec.describe "AppsV1s", type: :request do
	context '#index' do
		let!(:url) { '/api/v1/applications' }

		context 'When there are no applications' do 
			it 'should return an empty list' do
				get url 
				expect(response.status).to eq 200
				expect(JSON.parse(response.body)['data']).to eq []
			end
		end
		context 'When there are some Applications created' do
			before do
				App.create(name: "App1", token:"a1234")
				App.create(name: "App2", token:"b1234")
				App.create(name: "App3", token:"c1234")
			end

			let!(:expected_response) do
				JSON.parse(File.read("#{Rails.root}/spec/fixtures/applications/application_data.json"))
			end

			it 'should return an array of all created records' do
				get url
				expect(response.status).to eq 200
				expect(response.body).to eq expected_response.to_json
			end
		end
	end

	context '#show' do
		let!(:token) { "b1234" }
		let!(:url) { "/api/v1/applications/#{token}" }
		context 'When requesting non valid token' do 
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
		context 'When requesting a valid token' do
			before do
				App.create(name: "App1", token:"b1234")
			end

			let!(:expected_response) {'{"data":{"name":"App1","token":"b1234","chats_count":0}}'.to_json}
						it 'should return correct data of the app' do
				get url
				expect(response.status).to eq 200
				expect(response.body.to_json).to eq expected_response
			end
		end
	end

	context '#create' do
		let!(:url) { "/api/v1/applications" }
		let!(:params) do
			{
				app: {
					name: "App1"
				}
			}
		end
		context 'When creating with valid token' do 
			it 'should increment the count' do
				expect{ post url, params: params }.to change{ App.count }.from(0).to(1)
			end
			it 'should be created with correct name and chats count' do
				post url, params: params

				expect( App.first.name ).to eq params[:app][:name]
				expect( App.first.chats_count).to eq 0
			end
		end

		context 'When creating with non valid token' do
			before do
				App.create(name: "App1", token:"a1234")
			end
			it 'should return an error' do    
				expect { App.create(name: "App2", token:"a1234") }.to raise_error(ActiveRecord::RecordNotUnique)
			end
		end
		context 'When creating with non valid params' do 
			let!(:expected_error){"param is missing or the value is empty: app"}
			it 'raise a param is missing error' do
				post url, params: {}
				expect(response.status).to eq 422
				expect(JSON.parse(response.body)['error']).to eq expected_error
			end
		end
		context 'When creating with empty name' do 
			before do
				App.create(name: "App2", token:"a1234")
			end
			it 'raise a unprocessable entity error with null value' do
				post url, params: {app:{name:nil}}
				expect(response.status).to eq 422
				expect(JSON.parse(response.body)['error']).to eq "Invalid App Name"
			end
			it 'raise a unprocessable entity error with empty value' do
				post url, params: {app:{name:""}}
				expect(response.status).to eq 422
				expect(JSON.parse(response.body)['error']).to eq "Invalid App Name"
			end
		end
	end

	context '#update' do
		let!(:token) { "a1234" }
		let!(:url) { "/api/v1/applications/#{token}" }
		let!(:params) do
			{
				app: {
					name: "App1"
				}
			}
		end
		context 'When updating with valid token' do 
			before do
				App.create(name: "App2", token:"a1234")
			end
			it 'should update the name correctly' do
				put url, params: params
				expect( App.first.name ).to eq params[:app][:name]
				expect( App.first.chats_count).to eq 0
			end
		end
		context 'When updating with non valid token' do 
			let!(:expected_response){"No App Found"}
			before do
				App.create(name: "App2", token:"b1234")
			end
			it 'should update the name correctly' do
				put url, params: params
				expect(response.status).to eq 404
				expect(JSON.parse(response.body)['data']).to eq expected_response
			end
		end

		context 'When updating with non valid params' do 
			let!(:expected_error){"param is missing or the value is empty: app"}
			before do
				App.create(name: "App2", token:"a1234")
			end
			it 'raise a param is missing error' do
				put url, params: {}
				expect(response.status).to eq 422
				expect(JSON.parse(response.body)['error']).to eq expected_error
			end
		end
		context 'When updating with empty name' do 
			before do
				App.create(name: "App2", token:"a1234")
			end
			it 'raise a unprocessable entity error with null value' do
				put url, params: {app:{name:nil}}
				expect(response.status).to eq 422
				expect(JSON.parse(response.body)['error']).to eq "Invalid App Name"
			end
			it 'raise a unprocessable entity error with empty value' do
				put url, params: {app:{name:""}}
				expect(response.status).to eq 422
				expect(JSON.parse(response.body)['error']).to eq "Invalid App Name"
			end
		end
	end
end

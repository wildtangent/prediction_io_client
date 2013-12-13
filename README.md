# PredictionIoClient

Re-work of the Prediction.IO Client library using more Ruby-friendly syntax and Faraday library for HTTP

## Installation

Add this line to your application's Gemfile:

    gem 'prediction_io_client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install prediction_io_client

## Usage

```ruby
# Get some users and items from your own Database
uid = User.find(1).id
iid = Camera.find(155).id

# Create a new client
predictor = FM::PredictionIO::Client.new(api_key, api_url)

# Add the user and item to the prediction engine
predictor.add_user(uid)
predictor.add_item(iid, 'camera')

# Record user behaviour
# TODO....

# Your engine is the name of your recommendation engine in Prediction.IO
engine = "awesome-predictor"

# Get 10 recommendation by item recommendation
predictor.identify(uid)
predictor.get_itemrec_top_n(engine, iid, 10)

# Get 10 recommendations by item similarity
predictor.identify(uid)
predictor.get_itemsim_top_n(engine, iid, 10)
```


## Running Tests

First create a `config.yml` in the root of the gem as follows:
Note the tests run against a live server at present.

```
api_url: "http://yourpredictionioserver.com:8000"
api_key: "yourpredictionioserverkey"
```

Then run the specs
```
bundle exec rake spec
```

## TODO
* Implement mocks for test HTTP responses
* Finish testing implementation

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

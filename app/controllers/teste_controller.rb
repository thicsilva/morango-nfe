# creating a fake list
    cities = Client.select('distinct name').order(:name)
    fruits = ['Manana', 'Molango', 'Bacate', 'Acabaxi']

    list = []
    cities.each{|city| fruits.each{|fruit| list.push({city: city, product: fruit, count: rand(10..100)}) }}

    puts list

    # this will hold the crosstab
    @myCities = {}

    # this will hold the unique products for the header
    @uniqProducts = {}

    # Creating crosstab structure
    list.each{|row|
      cityName    = row[:city]
      productName = row[:product]
      @uniqProducts[ productName ] = true;

      # cria um hash vazio se aquela chave ainda nao existe
      @myCities[ cityName ] = {} if @myCities[ cityName ].nil?

      @myCities[ cityName ][ productName ] = row[:count]
    }

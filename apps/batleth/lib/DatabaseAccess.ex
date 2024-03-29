defmodule DatabaseAccess do
	use GenServer
	use Database

	@supervision_name :base

	@doc """
		Starts databaseaccess.
	"""
	def start_link(_, _) do
		Amnesia.start
		GenServer.start(__MODULE__,  [], [name: @supervision_name])
	end
#api
	@doc """ 
		Get a record with a parameter at
		
		Actually, it is only used for getting the last timestamp, so at = :last_timestamp
		Possible responses:
			{:ok, last_timestamp}
			{:ok, 0} - if there are not records in the Database
			{:error, :db}
		"""
	def get(at) do
		GenServer.call(@supervision_name, {:get, at})
	end
	
	@doc """
		Get a list of records that meet the conditions: timestamp >= from and timestamp <= to
		Returns a list of Database.Wpis struct
				
		Example return: [%Database.Wpis{pr: 92, status: 1, timestamp: 1438332598},
 				%Database.Wpis{pr: 92, status: 1, timestamp: 1438332658}]
	"""

	def get(from, to) do
		GenServer.call(@supervision_name, {:get, from, to})
	end

	@doc """
		Adds record to the database. Requires map %{status, pr}. Returns {:ok} when added, {:error, :db} 			otherwise
		"""

	def add(at) do
		GenServer.call(@supervision_name, {:add, at})
	end


	#Implemtation	
	defp no_db do
		Logging.write(:no_db)
	end

	def handle_call({:get, :last_timestamp}, _, _) do
		case Wpis.getLast() do
                	nil -> {:reply, {:ok, 0}, []}
                        l when is_integer(l) -> {:reply, {:ok, l}, []}
                        _ ->    no_db
				{:reply, {:error, :db}, []}
		end
	end
	
	def handle_call({:get, from, to}, _, _) do
		{:reply, Wpis.get(from, to), []}
	end


	def handle_call({:get, :last}, _, _) do
		tmp = Wpis.getLast()
		{:reply, Wpis.get(tmp), []}
	end

	
	def handle_call({:add, %{status: stat, pr: per}}, _, _) do
		case Wpis.parse_wpis(per, stat) |> Wpis.add do
			l when is_map(l) -> {:reply, {:ok}, []}
			nil -> 
				no_db
				{:reply, {:error, :db}, []}
		end
	end
end



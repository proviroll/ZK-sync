const { Client } = require('pg');

const client = new Client({
	connectionString: 'postgres://postgres:<pw>@localhost:5432',
});

client
	.connect()
	.then(() => {
		console.log('Connected successfully!');
		return client.end();
	})
	.catch((err) => console.error('Connection error', err.stack));

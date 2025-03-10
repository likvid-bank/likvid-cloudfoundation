const ionoscloud = require('@ionos-cloud/sdk-nodejs');

// IONOS Cloud Config
const config = new ionoscloud.Configuration({
    username: process.env.IONOS_USERNAME,
    password: process.env.IONOS_PASSWORD,
    apiKey: process.env.IONOS_API_KEY // Optional
});

const userManagementApi = new ionoscloud.UserManagementApi(config);

// Get User from ENV
const meshUsers = JSON.parse(process.env.MESH_USERS || '[]');

// Extract Users from MESH_USERS
const users = meshUsers.map((user) => ({ email: user.email, firstname: user.firstName, lastname: user.lastName }));

async function createUser(user) {
    const { email, firstname, lastname } = user;
    const password = Math.random().toString(36).slice(-12); // random User-Password
    const administrator = false;

    try {
        const existingUsersResponse = await userManagementApi.umUsersGet();
        const existingUsers = existingUsersResponse.items || [];

        if (existingUsers.some((u) => u.properties.email === email)) {
            console.log(`User ${email} already exists. Skipping...`);
            return;
        }

        const userData = {
            properties: { firstname, lastname, email, password, administrator }
        };

        const createResponse = await userManagementApi.umUsersPost({ user: userData });
        console.log(`User ${email} created successfully!`, createResponse);
    } catch (error) {
        console.error(`Error processing user ${email}:`, error.response ? error.response.data : error.message);
    }
}

// run the user creation process
async function processUsers() {
    for (const user of users) {
        await createUser(user);
    }
}

processUsers();

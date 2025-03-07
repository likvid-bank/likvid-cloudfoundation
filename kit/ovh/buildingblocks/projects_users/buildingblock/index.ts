var ovh = require('ovh')({
  appKey: process.env.OVH_APPLICATION_KEY,
  appSecret: process.env.OVH_APPLICATION_SECRET,
  consumerKey: process.env.OVH_CONSUMER_KEY
});

// Benutzer aus Umgebungsvariable einlesen
const meshUsers = JSON.parse(process.env.MESH_USERS || '[]');

// Alle Benutzer aus MESH_USERS extrahieren (unabhängig von der Rolle)
const users = meshUsers.map((user) => ({ email: user.email }));

// Funktion zum Überprüfen und Erstellen eines Benutzers
async function createUser(userEmail) {
  const login = userEmail.split('@')[0];
  const group = 'DEFAULT';
  const description = 'Likvid OVH Platform User';
  const password = Math.random().toString(36).slice(-12); // Zufälliges Passwort

  try {
    const existingUsers = await ovh.requestPromised('GET', '/me/identity/user').catch(() => []);

    if (!Array.isArray(existingUsers)) {
      console.error(`Error: Unexpected response for existing users:`, existingUsers);
      return;
    }

    if (existingUsers.some((user) => user.login === login)) {
      console.log(`User ${userEmail} already exists. Skipping...`);
      return;
    }

    const userData = { description, email: userEmail, group, login, password };
    const createResponse = await ovh.requestPromised('POST', '/me/identity/user', userData);

    console.log(`User ${userEmail} created successfully!`, createResponse);
  } catch (error) {
    console.error(`Error processing user ${userEmail}:`, error);
  }
}

// Alle Benutzer durchlaufen
async function processUsers() {
  for (const user of users) {
    await createUser(user.email);
  }
}

processUsers();

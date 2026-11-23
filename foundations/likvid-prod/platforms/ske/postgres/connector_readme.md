This building block gives your namespace a **PostgreSQL database** on the platform's shared
STACKIT PostgreSQL Flex instance. The platform team runs the server, patches it and takes the
backups. You order it without filling in anything.

## 🎯 What you get

- **A database and its owner user**, both named `<workspace>_<project>`, on the shared instance of
  your landing zone: a single node for `ske-namespace-dev`, three replicated nodes for
  `ske-namespace-prod`.
- **A Kubernetes Secret `postgres`** in your namespace with the keys `SPRING_DATASOURCE_URL`,
  `SPRING_DATASOURCE_USERNAME` and `SPRING_DATASOURCE_PASSWORD`. A Spring Boot pod reads all three
  with `envFrom`. The password is stored nowhere else.
- **Isolation.** No other user of the shared instance can connect to your database. The platform
  team sets this up outside your namespace and its quota.

## 🚀 After the order

Running pods do not see a new Secret. Run your pipeline again for the stage, with a push or a
manual run of the workflow, so that the next deployment starts pods that read it.

## 🔌 Connecting

The connection requires TLS (`sslmode=require`) and works from the platform's cluster only.

## 📊 Shared Responsibility

| Responsibility | Platform Team | Application Team |
|---|:---:|:---:|
| Operate the server, patch it and take backups | ✅ | ❌ |
| Size and availability of the shared instances | ✅ | ❌ |
| Create the database, its owner and the Secret | ✅ | ❌ |
| Redeploy the application after the order | ❌ | ✅ |
| Schema, migrations and query performance | ❌ | ✅ |
| Keep the credentials in the Secret confidential | ❌ | ✅ |

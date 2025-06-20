---
applyTo: '/kit/foundation/meshstack/guides/**.md'
---

# meshStack Guide: Demo Story

## **What is a Demo Story?**

A **demo story** is a structured narrative used to showcase meshStack product functionality in a realistic, relatable
 scenario. It simulates how a customer (or internal team) might use a specific feature or service, guiding prospects or stakeholders through its capabilities and value in a tangible, repeatable way.

Demo stories are designed to be reusable and continuously improved to ensure consistency, clarity, and relevance across sales, onboarding, and internal enablement activities.

## **Purpose of a Demo Story**

- **Drive Value-Based Conversations:** Illustrate how your platform solves real-world problems.
- **Enable Repeatable Demos:** Standardize demos across sales and technical teams.
- **Support Continuous Improvement:** Collect feedback to refine and evolve the demo over time.
- **Reduce Complexity:** Simplify complex functionality through relatable examples.
- **Build Confidence:** Help customers and internal users understand how to implement solutions using your platform.

# **Demo Story Structure**

### 1. **Title**

A short, descriptive title of the scenario.

### 2. **Motivation / Business Context**

Describe the fictional or anonymized company and its goals.

### 3. **Challenges**

Explain the problems or blockers the platform aims to solve.

### 4. **Implementation Steps**

If available, this section should link to a StoryLane video that walks through the demo story.

Walk through the setup and usage of the feature being demoed.

- Setup prerequisites (e.g., GitHub App)
- Platform configuration (e.g., Custom Platform in meshStack)
- Service publishing
- Consumption by end users (Application teams)

### 5. **Conclusion**

Summarize the value demonstrated and encourage next steps or learning.

# Formatting Requirements for Demo Stories

We write demo stories as terraform templated markdown files. 
This allows us to tightly interweave the Livkid Bank cloud foundation IaC code that setups up their meshStack environment
with the generated documentation. This is important to ensure that the demo story is always up-to-date with the
actual deployed environment.




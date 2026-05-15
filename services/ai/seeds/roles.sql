INSERT INTO roles (name, description, created_at, updated_at)
VALUES 
  ('user', 'Basic user with access to account features like wallet, transactions, and support.', NOW(), NOW()),
  ('admin', 'Administrator with elevated permissions to manage users, monitor transactions, and support tickets.', NOW(), NOW()),
  ('superAdmin', 'Super administrator with full access across the system including roles, permissions, and configurations.', NOW(), NOW()),
  ('compliance', 'Handles KYC, fraud detection, and compliance-related tasks.', NOW(), NOW()),
  ('support', 'Handles user issues and support tickets.', NOW(), NOW()),
  ('auditor', 'Read-only role for financial audit and reporting.', NOW(), NOW());
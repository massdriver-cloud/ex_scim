# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### ex_scim
#### Added
- Core SCIM v2.0 library implementation
- User and group resource management
- Bulk operations support
- Schema validation
- Query filter parsing and adapter pattern
- Storage adapter behaviour with ETS-based implementation
- Authentication provider adapter pattern
- Resource scope validation
- SCIM error response helpers
- Initial test suite

### ex_scim_client
#### Added
- HTTP client for consuming SCIM APIs
- User and Group resource operations
- Request builder with authentication

### ex_scim_ecto
#### Added
- Ecto-based storage adapter
- Query filter adapter for Ecto integration

### ex_scim_phoenix
#### Added
- Phoenix integration for SCIM
- SCIM controllers and routing
- Authentication plugs and middleware
- Request logging
- Error handling improvements

### examples/provider
#### Added
- LiveView-based provider example
- User and group management interface
- Database migrations and seeds
- Authentication integration

#!/usr/bin/env -S falcon host
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

load :rack, :lets_encrypt_tls, :supervisor

hostname = File.basename(__dir__)
rack hostname, :lets_encrypt_tls

supervisor

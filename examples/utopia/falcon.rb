#!/usr/bin/env -S falcon host
# frozen_string_literal: true

load :rack, :lets_encrypt_tls, :supervisor

hostname = File.basename(__dir__)
rack hostname, :lets_encrypt_tls

supervisor

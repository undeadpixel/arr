require 'spec_helper'

describe Arr::Connection do

  let(:connection) { Arr::Connection.new(options) }
  let(:options) { {} }

  def port_status(port)
    socket = TCPSocket.new('', port)
    socket ? 'used' : 'opened'
  end

  describe '#new' do

    context 'with defaults' do
      it 'opens a server at an ephimerial port' do
        expect(TCPServer).to receive(:new).with("", 0).and_call_original
        connection
      end

      it 'creates one R interpreter' do
        expect(IO).to receive(:popen).with("R --slave --vanilla", "w+", kind_of(Hash)).and_call_original
        connection
      end
    end

    context "when R interpreter doesn't want to connect" do
      before do
        allow_any_instance_of(TCPServer).to receive(:accept) { Kernel.sleep(5) }
        Arr.server_accept_timeout = 0.1
      end

      it('raises an Arr::Error') { expect { connection }.to raise_error(Arr::Error, "Timeout connecting interpreter with server") }

      after { Arr.server_accept_timeout = 10 }
    end

  end

  describe '#query' do

    subject { connection.query(query) }

    context 'when passing valid R' do
      
      let(:query) { "a = 3; b = 2; a + b" }
      let(:json_response) { "{\"type\":\"double\",\"attributes\":{},\"value\":[5]}" }

      it 'calls Arr::RObject.factory to convert result' do
        expect(Arr::RObject).to receive(:factory).with(json_response).and_call_original
        subject
      end
    end

    context 'when passing invalid R' do
      let(:query) { "a = 3b = 2" }
      it('raises an Arr::Error') { expect { subject }.to raise_error(Arr::Error, "Query has a parse error") }
    end

    context 'when the query hits timeout' do
      before { Arr.interpreter_query_timeout = 0.1 }

      let(:query) { "Sys.sleep(0.1)" }

      it('raises an Arr::Error') { expect { subject }.to raise_error(Arr::Error, "Timeout executing query") }

      after { Arr.interpreter_query_timeout = 60 }
    end

  end
end

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

    # TODO: treat each type of data differently (at least basic stuff!!)
    context 'when R returns a float' do
      let(:query) { "a = 2; b = 3; a + b" }

      it('returns a float in ruby') { expect(subject).to eq(5.0) }
    end

    context 'when R returns a string' do
      let(:query) { "'hello'" }

      it('returns a string in ruby') { expect(subject).to eq('hello') }
    end
    
    context 'when R returns a boolean' do
      let(:query) { "FALSE" }

      it('returns a boolean in ruby') { expect(subject).to be false }
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

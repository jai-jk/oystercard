require 'oystercard'

describe Oystercard do

    it 'should default balance to DEFAULT_BALANCE' do
        expect(subject.balance).to eq(Oystercard::DEFAULT_BALANCE)
    end

    it 'should add :top_up(amount) to :balance' do
        expect { subject.top_up(5) }.to change { subject.balance }.by(5)
    end

    it "should default maximum balance to £90" do
        expect(Oystercard::MAX_BALANCE).to eq 90
    end

    it 'should raise an error when deposit exceeds maximum amount' do
        subject.instance_variable_set(:@balance, Oystercard::MAX_BALANCE)
        expect { subject.top_up(1) }.to raise_error("Balance cannot exceed maximum of £#{Oystercard::MAX_BALANCE}")
    end

    it "should not be in a journey at beginning" do
        expect(Oystercard.new().in_journey?).to eq false
    end

    describe "touches in and out" do
        before do
            subject.top_up(1)
        end

        it "touches in" do
            subject.touch_in()
            expect(subject.in_journey?).to eq true
        end

        it "touches out" do
            subject.touch_in
            subject.touch_out
            expect(subject.in_journey?).to eq false
        end
    end

    it 'should set minimum fare to £1' do
        expect(Oystercard::MIN_FARE).to eq 1
    end

    it 'should raise an error if user tries to touch in with a balance less than MIN_FARE' do
        expect { subject.touch_in }.to raise_error("Insufficient balance on card")
    end

    it 'should deduct MIN_FARE when user touches out' do
        subject.top_up(Oystercard::MIN_FARE)
        subject.touch_in
        expect { subject.touch_out }.to change { subject.balance }.by(-Oystercard::MIN_FARE)
    end

   context 'for user journey' do
        before do
            subject.top_up(Oystercard::MIN_FARE)
            subject.touch_in("waterloo")
            subject.touch_out("bank")
        end
        # let(:exit_station){ subject.touch_out("bank") }

        # it 'should remember the entry station after touch_in' do
        #     expect(subject.entry_station).to eq :waterloo
        # end

        it 'when touched out - should set entry_station to nil' do
            subject.touch_out
            expect(subject.entry_station).to be_nil
        end

        it 'should return an array of stored trips' do
            expect(subject.show_trips).to be_a(Array)
        end

        it 'should store entry_station in show_trips' do
            expect(subject.show_trips[0]).to include("entry" => :waterloo)
        end

        it { is_expected.to respond_to(:touch_out).with(1).argument }

        it 'should remember the exit station after touch_out' do
            expect(subject.exit_station).to eq :bank
        end

        it 'should store exit_station in show_trips' do
            expect(subject.show_trips[0]).to include("exit" => :bank)
        end

        it 'should store the first journey in a hash' do
            expect(subject.show_trips[0]).to eq({ "entry" => :waterloo, "exit" => :bank })
        end
    end
end

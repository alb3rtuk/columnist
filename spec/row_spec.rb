require 'spec_helper'

describe Anchorman::Row do
  let(:cols) { 10.times.map {|v| Anchorman::Column.new("test#{v}")} }

  describe '#initialize' do
    it 'accepts header' do
      expect(Anchorman::Row.new(:header => true).header).to be_true
    end

    it 'accepts color' do
      expect(Anchorman::Row.new(:color => 'red').color).to eq('red')
    end

    it 'accepts bold' do
      expect(Anchorman::Row.new(:bold => true).bold).to be_true
    end

    it 'output encoding should be ascii' do
      expect(Anchorman::Row.new(:encoding => :ascii).encoding).to eq(:ascii)
    end

    it 'output encoding should be unicode' do
      expect(Anchorman::Row.new.encoding).to eq(:unicode)
    end

  end

  describe '#add' do
    subject { Anchorman::Row.new }

    it 'columns' do
      subject.add(cols[0])
      expect(subject.columns.size).to eq(1)
      expect(subject.columns[0]).to eq(cols[0])
      subject.add(cols[1])
      expect(subject.columns).to eq(cols[0,2])
    end

    it 'defaults colors on columns' do
      row = Anchorman::Row.new(:color => 'red')
      row.add(cols[0])
      expect(row.columns[0].color).to eq('red')
      row.add(cols[1])
      expect(row.columns[1].color).to eq('red')
    end

    it 'allows columns to override the row color' do
      col = Anchorman::Column.new('test', :color => 'blue')
      row = Anchorman::Row.new(:color => 'red')
      row.add(col)
      expect(row.columns[0].color).to eq('blue')
    end

    it 'supercedes bold on columns' do
      row = Anchorman::Row.new(:bold => true)
      row.add(cols[0])
      expect(row.columns[0].bold).to be_true
      row.add(cols[1])
      expect(row.columns[1].bold).to be_true
    end
  end

  describe '#output' do
    let :cols do
      [
        Anchorman::Column.new('asdf'),
        Anchorman::Column.new('qwer', :align => 'center'),
        Anchorman::Column.new('zxcv', :align => 'right'),
        Anchorman::Column.new('x' * 25, :align => 'left', :width => 10),
        Anchorman::Column.new('x' * 25, :align => 'center', :width => 10),
        Anchorman::Column.new('x' * 35, :align => 'left', :width => 10),
      ]
    end

    let(:one_space) { ' ' }
    let(:three_spaces) { ' {3,3}' }
    let(:six_spaces) { ' {6,6}' }
    let(:nine_spaces) { ' {9,9}' }
    let(:five_xs) { 'x{5,5}' }
    let(:ten_xs) { 'x{10,10}' }

    context 'no border' do
      context 'no wrap' do
        it 'outputs a single column' do
          subject.add(cols[0])
          expect(subject).to receive(:puts).with(/^asdf#{@six_pieces}/)
          subject.output
        end
        it 'outputs three columns' do
          subject.add(cols[0])
          subject.add(cols[1])
          subject.add(cols[2])
          expect(subject).to receive(:puts).with(/^asdf#{six_spaces}#{one_space}#{three_spaces}qwer#{three_spaces}#{one_space}#{six_spaces}zxcv $/)
          subject.output
        end
      end

      context 'with wrapping' do
        it 'outputs a single column' do
          subject.add(cols[3])
          expect(subject).to receive(:puts).with(/^#{ten_xs}#{one_space}$/)
          expect(subject).to receive(:puts).with(/^#{ten_xs}#{one_space}$/)
          expect(subject).to receive(:puts).with(/^#{five_xs}#{six_spaces}$/)
          subject.output
        end

        it 'outputs multiple columns of the same size' do
          subject.add(cols[3])
          subject.add(cols[4])
          expect(subject).to receive(:puts).with(/^#{ten_xs}#{one_space}#{ten_xs}#{one_space}$/)
          expect(subject).to receive(:puts).with(/^#{ten_xs}#{one_space}#{ten_xs}#{one_space}$/)
          expect(subject).to receive(:puts).with(/^#{five_xs}#{nine_spaces}#{five_xs}#{three_spaces}$/)
          subject.output
        end

        it 'outputs multiple columns with different sizes' do
          subject.add(cols[5])
          subject.add(cols[3])
          expect(subject).to receive(:puts).with(/^#{ten_xs}#{one_space}#{ten_xs}#{one_space}$/)
          expect(subject).to receive(:puts).with(/^#{ten_xs}#{one_space}#{ten_xs}#{one_space}$/)
          expect(subject).to receive(:puts).with(/^#{ten_xs}#{one_space}#{five_xs}#{six_spaces}$/)
          expect(subject).to receive(:puts).with(/^#{five_xs} {5,17}$/)
          subject.output
        end
      end
    end
  end
end

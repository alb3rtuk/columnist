require 'spec_helper'

describe Anchorman::Table do
  context 'creation' do
    it 'defaults options hash' do
      expect {
        Anchorman::Table.new
      }.to_not raise_error
    end

    it 'defaults the border' do
      expect(Anchorman::Table.new.border).to be_false
    end

    it 'accepts the border' do
      expect(Anchorman::Table.new(:border => true).border).to eq(true)
    end

    it 'defaults the border_color' do
      expect(Anchorman::Table.new.border_color).to be_false
    end

    it 'accepts the border_color' do
      expect(Anchorman::Table.new(:border_color => true).border_color).to eq(true)
    end

    it 'output encoding should be ascii' do
      expect(Anchorman::Table.new(:encoding => :ascii).encoding).to eq(:ascii)
    end

    it 'output encoding should be unicode' do
      expect(Anchorman::Table.new.encoding).to eq(:unicode)
    end
  end

  context 'rows' do
    it 'allows addition' do
      cols = [Anchorman::Column.new('test1'), Anchorman::Column.new('test2')]
      row = Anchorman::Row.new
      cols.each {|c| row.add(c)}
      expect {
        Anchorman::Table.new.add(row)
      }.to_not raise_error
    end

    context 'inherits' do
      before :each do
        @table = Anchorman::Table.new
        row = Anchorman::Row.new(:color => 'red')
        (
          @cols1 = [
            Anchorman::Column.new('asdf', :width => 5),
            Anchorman::Column.new('qwer', :align => 'right', :color => 'purple'),
            Anchorman::Column.new('tutu', :color => 'green'),
            Anchorman::Column.new('uiui', :bold => true),
          ]
        ).each {|c| row.add(c)}
        @table.add(row)
        row = Anchorman::Row.new
        (@cols2 = [
            Anchorman::Column.new('test'),
            Anchorman::Column.new('test'),
            Anchorman::Column.new('test', :color => 'blue'),
            Anchorman::Column.new('test'),
          ]
        ).each {|c| row.add(c)}
        @table.add(row)
      end

      it 'positional attributes' do
        [:align, :width, :size, :padding].each do |m|
          4.times do |i|
            expect(@table.rows[1].columns[i].send(m)).to eq(@table.rows[0].columns[i].send(m))
          end
        end
      end

      context 'no header row' do
        it 'color' do
          expect(@table.rows[1].columns[0].color).to eq('red')
          expect(@table.rows[1].columns[1].color).to eq('purple')
          expect(@table.rows[1].columns[2].color).to eq('blue')
          expect(@table.rows[1].columns[3].color).to eq('red')
        end

        it 'bold' do
          expect(@table.rows[1].columns[0].bold).to be_false
          expect(@table.rows[1].columns[1].bold).to be_false
          expect(@table.rows[1].columns[2].bold).to be_false
          expect(@table.rows[1].columns[3].bold).to be_true
        end
      end

      context 'with header row' do
        before :each do
          @table = Anchorman::Table.new
          row = Anchorman::Row.new(:header => true)
          @cols1.each {|c| row.add(c)}
          @table.add(row)
          row = Anchorman::Row.new
          @cols2.each {|c| row.add(c)}
          @table.add(row)
        end

        it 'color' do
          expect(@table.rows[1].columns[0].color).to eq('red')
          expect(@table.rows[1].columns[1].color).to eq('purple')
          expect(@table.rows[1].columns[2].color).to eq('blue')
          expect(@table.rows[1].columns[3].color).to eq('red')
        end

        it 'bold' do
          expect(@table.rows[1].columns[0].bold).to be_false
          expect(@table.rows[1].columns[0].bold).to be_false
          expect(@table.rows[1].columns[1].bold).to be_false
          expect(@table.rows[1].columns[2].bold).to be_false
          expect(@table.rows[1].columns[3].bold).to be_true
        end
      end
    end
  end

  
  describe '#auto_adjust_widths' do
    it 'sets the widths of each column in each row to the maximum required width for that column' do
      table = Anchorman::Table.new.tap do |t|
        t.add(
          Anchorman::Row.new.tap do |r|
            r.add Anchorman::Column.new('medium length')
            r.add Anchorman::Column.new('i am pretty long') # longest column
            r.add Anchorman::Column.new('short', :padding => 100)
          end
        )

        t.add(
          Anchorman::Row.new.tap do |r|
            r.add Anchorman::Column.new('longer than medium length') # longest column
            r.add Anchorman::Column.new('shorter')
            r.add Anchorman::Column.new('longer than short') # longest column (inherits padding)
          end
        )
      end

      table.auto_adjust_widths

      table.rows.each do |row|
        expect(row.columns[0].width).to eq(Anchorman::Column.new('longer than medium length').required_width)
        expect(row.columns[1].width).to eq(Anchorman::Column.new('i am pretty long').required_width)
        expect(row.columns[2].width).to eq(Anchorman::Column.new('longer than short', :padding => 100).required_width)
      end
    end
  end

end

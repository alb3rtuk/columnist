require 'spec_helper'

describe Columnist do
    let :use_class do
        Class.new do
            include Columnist
        end
    end

    let(:timestamp_regex) { /\d{4}-\d{2}-\d{2} - (\d| )\d:\d{2}:\d{2}[AP]M/ }

    let :controls do
        {
            :clear => "\e[0m",
            :bold  => "\e[1m",
            :red   => "\e[31m",
        }
    end

    let(:linechar) { "\u2501" == 'u2501' ? '-' : "\u2501" }

    subject { use_class.new }

    describe '#formatter=' do
        it 'only allows allowed formatters' do
            expect {
                subject.formatter = 'asfd'
            }.to raise_error ArgumentError
        end

        it 'specifies the progress formatter' do
            subject.formatter = 'progress'
            expect(subject.formatter.class).to eq(Columnist::ProgressFormatter)
        end

        it 'specifies the nested formatter' do
            subject.formatter = 'nested'
            expect(subject.formatter.class).to eq(Columnist::NestedFormatter)
        end
    end

    describe '#report' do
        it 'uses the nested formatter as default' do
            capture_stdout {
                subject.report {}
            }

            expect(subject.formatter.class).to eq(Columnist::NestedFormatter)
        end

        it 'uses the progress formatter' do
            capture_stdout {
                subject.formatter = 'progress'
                subject.report {}
            }

            expect(subject.formatter.class).to eq(Columnist::ProgressFormatter)
        end

        it 'does not mask other application errors when a formatter is not set' do
            capture_stdout {
                subject.report {
                    expect { self.some_method_that_does_not_exist }.to raise_error(NoMethodError)
                }
            }
        end
    end

    describe '#header' do
        context 'argument validation' do

            it 'does not accept an invalid option' do
                expect {
                    subject.header(:asdf => 'tests')
                }.to raise_error ArgumentError
            end

            it 'accepts a title' do
                expect {
                    allow(subject).to receive(:puts)
                    subject.header(:title => 'test')
                }.to_not raise_error
            end

            it 'does not allow a title > width' do
                expect {
                    subject.header(:title => 'xxxxxxxxxxx', :width => 5)
                }.to raise_error ArgumentError
            end

            it 'accepts width' do
                expect {
                    allow(subject).to receive(:puts)
                    subject.header(:width => 100)
                }.to_not raise_error
            end

            it 'ensure width is a number' do
                expect {
                    subject.header(:width => '100')
                }.to raise_error ArgumentError
            end

            it 'accepts align' do
                expect {
                    allow(subject).to receive(:puts)
                    subject.header(:align => 'center')
                }.to_not raise_error
            end

            it 'ensure align is a valid value' do
                expect {
                    subject.header(:align => :asdf)
                }.to raise_error ArgumentError
            end

            it 'accepts spacing' do
                expect {
                    allow(subject).to receive(:puts)
                    subject.header(:spacing => 2)
                }.to_not raise_error
            end

            it 'accepts timestamp' do
                expect {
                    allow(subject).to receive(:puts)
                    subject.header(:timestamp => true)
                }.to_not raise_error
            end

            it 'accepts color' do
                expect {
                    allow(subject).to receive(:puts)
                    subject.header(:color => 'red')
                }.to_not raise_error
            end

            it 'accepts bold' do
                expect {
                    allow(subject).to receive(:puts)
                    subject.header(:bold => true)
                }.to_not raise_error
            end
        end

        context 'alignment' do
            before :each do
                @title = 'test11test'
            end

            it 'left aligns title by default' do
                expect(subject).to receive(:puts).with(@title)
                expect(subject).to receive(:puts).with("\n")
                subject.header(:title => @title) {}
            end

            it 'left aligns title' do
                expect(subject).to receive(:puts).with(@title)
                expect(subject).to receive(:puts).with("\n")
                subject.header(:title => @title, :align => 'left') {}
            end

            it 'right aligns title using default width' do
                expect(subject).to receive(:puts).with(' ' * 90 + @title)
                expect(subject).to receive(:puts).with("\n")
                subject.header(:title => @title, :align => 'right')
            end

            it 'right aligns title using specified width' do
                expect(subject).to receive(:puts).with(' ' * 40 + @title)
                expect(subject).to receive(:puts).with("\n")
                subject.header(:title => @title, :align => 'right', :width => 50)
            end

            it 'center aligns title using default width' do
                expect(subject).to receive(:puts).with(' ' * 45 + @title)
                expect(subject).to receive(:puts).with("\n")
                subject.header(:title => @title, :align => 'center')
            end

            it 'center aligns title using specified width' do
                expect(subject).to receive(:puts).with(' ' * 35 + @title)
                expect(subject).to receive(:puts).with("\n")
                subject.header(:title => @title, :align => 'center', :width => 80)
            end
        end

        context 'spacing' do
            it 'defaults to a single line of spacing between report' do
                expect(subject).to receive(:puts).with('title')
                expect(subject).to receive(:puts).with("\n")
                subject.header(:title => 'title')
            end

            it 'uses the defined spacing between report' do
                expect(subject).to receive(:puts).with('title')
                expect(subject).to receive(:puts).with("\n" * 3)
                subject.header(:title => 'title', :spacing => 3)
            end
        end

        context 'timestamp subheading' do
            it 'is added with default alignment' do
                expect(subject).to receive(:puts).with('title')
                expect(subject).to receive(:puts).with(/^#{timestamp_regex}/)
                expect(subject).to receive(:puts).with("\n")
                subject.header(:title => 'title', :timestamp => true)
            end

            it 'added with right alignment' do
                expect(subject).to receive(:puts).with(/^ *title$/)
                expect(subject).to receive(:puts).with(/^ *#{timestamp_regex}$/)
                expect(subject).to receive(:puts).with("\n")
                subject.header(:title => 'title', :align => 'right', :timestamp => true, :width => 80)
            end

            it 'added with center alignment' do
                expect(subject).to receive(:puts).with(/^ *title *$/)
                expect(subject).to receive(:puts).with(/^ *#{timestamp_regex} *$/)
                expect(subject).to receive(:puts).with("\n")
                subject.header(:title => 'title', :align => 'center', :timestamp => true, :width => 80)
            end
        end

        context 'horizontal rule' do
            it 'uses dashes by default' do
                expect(subject).to receive(:puts)
                expect(subject).to receive(:puts).with(linechar * 100)
                expect(subject).to receive(:puts)
                subject.header(:rule => true)
            end

            it 'uses = as the rule character' do
                expect(subject).to receive(:puts)
                expect(subject).to receive(:puts).with('=' * 100)
                expect(subject).to receive(:puts)
                subject.header(:rule => '=')
            end
        end

        context 'color' do
            it 'single red line' do
                expect(subject).to receive(:puts).with(controls[:red] + 'Report' + controls[:clear])
                expect(subject).to receive(:puts)
                subject.header(:color => 'red')
            end

            it 'multimple red lines' do
                expect(subject).to receive(:puts).with(controls[:red] + 'Report' + controls[:clear])
                expect(subject).to receive(:puts).with(controls[:red] + linechar * 100 + controls[:clear])
                expect(subject).to receive(:puts)
                subject.header(:color => 'red', :rule => true)
            end
        end

        context 'bold' do
            it 'single line' do
                expect(subject).to receive(:puts).with(controls[:bold] + 'Report' + controls[:clear])
                expect(subject).to receive(:puts)
                subject.header(:bold => true)
            end

            it 'multimple lines' do
                expect(subject).to receive(:puts).with(controls[:bold] + 'Report' + controls[:clear])
                expect(subject).to receive(:puts).with(controls[:bold] + linechar * 100 + controls[:clear])
                expect(subject).to receive(:puts)
                subject.header(:bold => true, :rule => true)
            end
        end
    end

    describe '#horizontal_rule' do
        context 'argument validation' do
            it 'does not allow invalid options' do
                expect {
                    subject.horizontal_rule(:asdf => true)
                }.to raise_error ArgumentError
            end

            it 'accepts char' do
                expect {
                    expect(subject).to receive(:puts)
                    subject.horizontal_rule(:char => '*')
                }.to_not raise_error
            end

            it 'accepts width' do
                expect {
                    expect(subject).to receive(:puts)
                    subject.horizontal_rule(:width => 10)
                }.to_not raise_error
            end
        end

        context 'drawing' do
            it 'writes a 100 yard dash by default' do
                expect(subject).to receive(:puts).with(linechar * 100)
                subject.horizontal_rule
            end

            it 'writes a 100 yard asterisk' do
                expect(subject).to receive(:puts).with('*' * 100)
                subject.horizontal_rule(:char => '*')
            end

            it 'writes a 50 yard equals' do
                expect(subject).to receive(:puts).with('=' * 50)
                subject.horizontal_rule(:char => '=', :width => 50)
            end
        end

        it 'outputs color' do
            expect(subject).to receive(:puts).with(controls[:red] + linechar * 100 + controls[:clear])
            subject.horizontal_rule(:color => 'red')
        end

        it 'outputs bold' do
            expect(subject).to receive(:puts).with(controls[:bold] + linechar * 100 + controls[:clear])
            subject.horizontal_rule(:bold => true)
        end
    end

    describe '#vertical_spacing' do
        it 'accepts a fixnum as a valid argument' do
            expect {
                subject.vertical_spacing('asdf')
            }.to raise_error ArgumentError
        end

        it 'prints carriage returns for the number of lines' do
            expect(subject).to receive(:puts).with("\n" * 3)
            subject.vertical_spacing(3)
        end
    end

    describe '#datetime' do
        context 'argument validation' do
            it 'does not allow invalid options' do
                expect {
                    subject.datetime(:asdf => true)
                }.to raise_error ArgumentError
            end

            it 'accepts align' do
                expect {
                    expect(subject).to receive(:puts)
                    subject.datetime(:align => 'left')
                }.to_not raise_error
            end

            it 'accepts width' do
                expect {
                    expect(subject).to receive(:puts)
                    subject.datetime(:width => 70)
                }.to_not raise_error
            end

            it 'accepts format' do
                expect {
                    expect(subject).to receive(:puts)
                    subject.datetime(:format => '%m/%d/%Y')
                }.to_not raise_error
            end

            it 'does not allow invalid width' do
                expect {
                    subject.datetime(:align => 'right', :width => 'asdf')
                }.to raise_error
            end

            it 'does not allow invalid align' do
                expect {
                    subject.datetime(:align => 1234)
                }.to raise_error
            end

            it 'does not allow a timestamp format larger than the width' do
                expect {
                    subject.datetime(:width => 8)
                }.to raise_error
            end
        end

        context 'display' do
            it 'a default format - left aligned' do
                expect(subject).to receive(:puts).with(/^#{timestamp_regex} *$/)
                subject.datetime
            end

            it 'a default format - right aligned' do
                expect(subject).to receive(:puts).with(/^ *#{timestamp_regex}$/)
                subject.datetime(:align => 'right')
            end

            it 'a default format - center aligned' do
                expect(subject).to receive(:puts).with(/^ *#{timestamp_regex} *$/)
                subject.datetime(:align => 'center')
            end

            it 'a modified format' do
                expect(subject).to receive(:puts).with(/^\d{2}\/\d{2}\/\d{2} *$/)
                subject.datetime(:format => '%y/%m/%d')
            end
        end

        it 'outputs color' do
            expect(subject).to receive(:puts).with(/^\e\[31m#{timestamp_regex}\e\[0m/)
            subject.datetime(:color => 'red')
        end

        it 'outputs bold' do
            expect(subject).to receive(:puts).with(/^\e\[1m#{timestamp_regex}\e\[0m/)
            subject.datetime(:bold => true)
        end
    end

    describe '#aligned' do
        context 'argument validation' do
            it 'accepts align' do
                expect {
                    allow(subject).to receive(:puts)
                    subject.aligned('test', :align => 'left')
                }.to_not raise_error
            end

            it 'does not allow invalid align values' do
                expect {
                    subject.aligned('test', :align => 1234)
                }.to raise_error ArgumentError
            end

            it 'accepts width' do
                expect {
                    allow(subject).to receive(:puts)
                    subject.aligned('test', :width => 40)
                }.to_not raise_error
            end

            it 'does not allow invalid width values' do
                expect {
                    subject.aligned('test', :align => 'right', :width => 'asdf')
                }.to raise_error
            end
        end

        it 'outputs color' do
            expect(subject).to receive(:puts).with(controls[:red] + 'x' * 10 + controls[:clear])
            subject.aligned('x' * 10, :color => 'red')
        end

        it 'outputs bold' do
            expect(subject).to receive(:puts).with(controls[:bold] + 'x' * 10 + controls[:clear])
            subject.aligned('x' * 10, :bold => true)
        end

    end

    describe '#footer' do
        context 'argument validation' do
            it 'accepts title' do
                expect {
                    allow(subject).to receive(:puts)
                    subject.footer(:title => 'test')
                }.to_not raise_error
            end

            it 'accepts align' do
                expect {
                    allow(subject).to receive(:puts)
                    subject.footer(:align => 'right')
                }.to_not raise_error
            end

            it 'does not accept invalid align' do
                expect {
                    subject.header(:align => 1234)
                }.to raise_error ArgumentError
            end

            it 'accepts width' do
                expect {
                    allow(subject).to receive(:puts)
                    subject.footer(:width => 50)
                }.to_not raise_error
            end

            it 'does not accept invalid width' do
                expect {
                    subject.footer(:width => 'asdf')
                }.to raise_error ArgumentError
            end

            it 'does not allow title > width' do
                expect {
                    subject.footer(:title => 'testtesttest', :width => 6)
                }.to raise_error ArgumentError
            end

            it 'accepts spacing' do
                expect {
                    allow(subject).to receive(:puts)
                    subject.footer(:spacing => 3)
                }.to_not raise_error
            end
        end

        context 'alignment' do
            before :each do
                @title = 'test12test'
            end

            it 'left aligns the title by default' do
                expect(subject).to receive(:puts).with("\n")
                expect(subject).to receive(:puts).with(@title)
                subject.footer(:title => @title)
            end

            it 'left aligns the title' do
                expect(subject).to receive(:puts).with("\n")
                expect(subject).to receive(:puts).with(@title)
                subject.footer(:title => @title, :align => 'left')
            end

            it 'right aligns the title' do
                expect(subject).to receive(:puts).with("\n")
                expect(subject).to receive(:puts).with(' ' * 90 + @title)
                subject.footer(:title => @title, :align => 'right')
            end

            it 'right aligns the title using width' do
                expect(subject).to receive(:puts).with("\n")
                expect(subject).to receive(:puts).with(' ' * 40 + @title)
                subject.footer(:title => @title, :align => 'right', :width => 50)
            end

            it 'center aligns the title' do
                expect(subject).to receive(:puts).with("\n")
                expect(subject).to receive(:puts).with(' ' * 45 + @title)
                subject.footer(:title => @title, :align => 'center')
            end

            it 'center aligns the title using width' do
                expect(subject).to receive(:puts).with("\n")
                expect(subject).to receive(:puts).with(' ' * 35 + @title)
                subject.footer(:title => @title, :align => 'center', :width => 80)
            end
        end

        context 'spacing' do
            it 'defaults to a single line of spacing between report' do
                expect(subject).to receive(:puts).with("\n")
                expect(subject).to receive(:puts).with('title')
                subject.footer(:title => 'title')
            end

            it 'uses the defined spacing between report' do
                expect(subject).to receive(:puts).with("\n" * 3)
                expect(subject).to receive(:puts).with('title')
                subject.footer(:title => 'title', :spacing => 3)
            end
        end

        context 'timestamp subheading' do
            it 'is added with default alignment' do
                expect(subject).to receive(:puts).with("\n")
                expect(subject).to receive(:puts).with('title')
                expect(subject).to receive(:puts).with(/^#{timestamp_regex}/)
                subject.footer(:title => 'title', :timestamp => true)
            end

            it 'added with right alignment' do
                expect(subject).to receive(:puts).with("\n")
                expect(subject).to receive(:puts).with(/^ *title$/)
                expect(subject).to receive(:puts).with(/^ *#{timestamp_regex}$/)
                subject.footer(:title => 'title', :align => 'right', :timestamp => true, :width => 80)
            end

            it 'added with center alignment' do
                expect(subject).to receive(:puts).with("\n")
                expect(subject).to receive(:puts).with(/^ *title *$/)
                expect(subject).to receive(:puts).with(/^ *#{timestamp_regex} *$/)
                subject.footer(:title => 'title', :align => 'center', :timestamp => true, :width => 80)
            end
        end

        context 'horizontal rule' do
            it 'uses dashes by default' do
                expect(subject).to receive(:puts)
                expect(subject).to receive(:puts).with(linechar * 100)
                expect(subject).to receive(:puts)
                subject.footer(:rule => true)
            end

            it 'uses = as the rule character' do
                expect(subject).to receive(:puts)
                expect(subject).to receive(:puts).with('=' * 100)
                expect(subject).to receive(:puts)
                subject.footer(:rule => '=')
            end
        end

        it 'outputs red' do
            expect(subject).to receive(:puts).with("\n")
            expect(subject).to receive(:puts).with(controls[:red] + 'title' + controls[:clear])
            expect(subject).to receive(:puts).with(/^\e\[31m#{timestamp_regex}\e\[0m/)
            subject.footer(:title => 'title', :timestamp => true, :color => 'red')
        end

        it 'outputs bold' do
            expect(subject).to receive(:puts).with("\n")
            expect(subject).to receive(:puts).with(controls[:bold] + 'title' + controls[:clear])
            expect(subject).to receive(:puts).with(/^\e\[1m#{timestamp_regex}\e\[0m/)
            subject.footer(:title => 'title', :timestamp => true, :bold => true)
        end
    end

    describe '#table' do
        it 'instantiates the table class' do
            allow(subject).to receive(:puts)
            expect(subject).to receive(:table).once
            subject.table {}
        end

        it 'requires a row to be defined' do
            expect {
                subject.table
            }.to raise_error LocalJumpError
        end

        it 'accepts valid options' do
            expect {
                subject.table(:border => true) {}
            }.to_not raise_error
        end

        it 'rejects invalid options' do
            expect {
                allow(subject).to receive(:puts)
                subject.table(:asdf => '100') {}
            }.to raise_error ArgumentError
        end
    end

    describe '#row' do
        it 'instantiates a row class' do
            expect(subject).to receive(:row).once
            allow(subject).to receive(:puts)

            subject.table do
                subject.row do
                end
            end
        end
    end

    describe '#column' do
        it 'instantiates multiple columns' do
            expect(subject).to receive(:column).exactly(3).times
            allow(subject).to receive(:puts)

            subject.table do
                subject.row do
                    subject.column('asdf')
                    subject.column('qwer')
                    subject.column('zxcv')
                end
            end
        end

        it 'accepts valid options' do
            expect(subject).to receive(:column).once
            allow(subject).to receive(:puts)

            subject.table do
                subject.row do
                    subject.column('asdf', :width => 30)
                end
            end
        end

        it 'rejects invalid options' do
            allow(subject).to receive(:puts)
            expect {
                subject.table do
                    subject.row do
                        subject.column('asdf', :asdf => 30)
                    end
                end
            }.to raise_error ArgumentError
        end
    end

end

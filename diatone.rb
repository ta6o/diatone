# coding: utf-8
### Yakup Cetinkaya 2012


module Diatone

  CHR = 12.0
  STEP = 2 ** (1/ CHR)
  TONES = ['C','C♯','D','D♯','E','F','F♯','G','G♯','A','A♯','B']
  SCALES = {
    '' => "221222",
    'm' => "212212",
  }
  CHORDS = {

    '' => [0,2,4],
    '6' => [0,2,4,5],
    '7' => [0,2,4,6.4],
    '9' => [0,2,4,6.4,8],
    '6/9' => [0,2,4,5.4,8],
    '11' => [0,2,4,6.4,8,10],
    '13' => [0,2,4,6.4,8,10,12],
    
    'maj7' => [0,2,4,6],
    'maj9' => [0,2,4,6,8],
    'maj11' => [0,2,4,6,8,10],
    'maj13' => [0,2,4,6,8,10,12],

    'm' => [0,2.4,4],
    'm6' => [0,2.4,4,5],
    'm7' => [0,2.4,4,6.4],
    'mM7' => [0,2.4,4,6],
    'm9' => [0,2.4,4,6.4,8],
    'm6/9' => [0,2.4,4,5.4,8],
    'm11' => [0,2.4,4,6.4,8,10],
    'm13' => [0,2.4,4,6.4,8,10,12],

    'sus2' => [0,1,4],
    'sus4' => [0,3,4],
    'dim' => [0,2.4,4.4],
    'dim7' => [0,2.4,4.4,6.3],
    '+' => [0,2,4.6],
    '-' => [0,2.4,4.4],
    '+5' => [0,2,4.6],
    '-5' => [0,2.4,4.4],
    'm-5' => [0,2.4,4.4],
    'majb5' => [0,2,4.4],
    '5' => [0,4]

  }
    
  class Note

    def self.ord2tone ( i, key = false )
      i += 48
      s = TONES[i% CHR]
      s = s + (i/ CHR).floor.to_s unless key
      return s
    end

    def self.tone2ord (s)
      if s[-2] == s[-2].to_i.to_s
        i = s[-2..-1].to_i * CHR
      elsif s[-1] == s[-1].to_i.to_s
        i = s[-1].to_i * CHR
      else
        i = 48
      end

      if s[1] == 'b' then i -= 1 elsif s[1] == '♯' then i += 1 end
      return i + TONES.rindex { |a| a == s[0].upcase } - 48
    end

    def self.fix(i)
      if i.is_a? Numeric
        return i
      end
      unless i.to_s[0] == i[0].to_i.to_s
        i = tone2ord(i)
      end
      return i
    end

    def self.key(s, ord=true)
      s = fix(s)
      s = ord2tone(s, true)
      unless ord
        return s
      end
      return TONES.rindex {|a| a == s }
    end

    def self.get (s)
      return [key(s,false)]
    end

    def self.name (s)
      return key(s,false)
    end

    def self.getFreq (i)
      i = fix(i)
      return 440.0 * ( STEP ** (i-9) )
    end

  end

  class Scale

    def self.abbr (t)
      t.gsub!(' major','')
      t.gsub!('major','')
      t.gsub!('maj','')
      t.gsub!(' minor','m')
      t.gsub!('minor','m')
      t.gsub!('min','m')
      return t
    end

    def self.get (s)
      if s.length > 1
        if s[1] == '♯' or s[1] == 'b'
          tonic = Note.key s[0..1]
          type = abbr(s[2..-1])
        else
          tonic = Note.key s[0]
          type = abbr(s[1..-1])
        end
      else
        tonic = Note.key s
        type = ''
      end
      i = Note.key(tonic)
      scale = [ TONES[i] ]
      if SCALES.include? type
        SCALES[type].split('').each do |interval|
          i += interval.to_i
          scale.push  TONES[i% CHR]
        end
      else
        return [false,type]
      end
      return scale
    end

    def self.name (s)
      if s[1] == '♯' or s[1] == 'b'
        note = Note.key s[0..1], false
        type = abbr(s[2..-1])
      else
        note = Note.key s[0], false
        type = abbr(s[1..-1])
      end
      return note+type
    end

  end
  
  class Chord

    def self.abbr (t)
      t.gsub!(' major','maj')
      t.gsub!('major','maj')
      t.gsub!(' minor','m')
      t.gsub!('minor','m')
      t.gsub!('min','m')
      t.gsub!('aug','+')
      return t
    end

    def self.get (s,relative=false)
      notes = []
      s.sub!("#","♯")
      if s[1] == '♯' or s[1] == 'b'
        scale = Scale.get s[0..1]
        type = abbr(s[2..-1])
      else
        scale = Scale.get s[0]
        type = abbr(s[1..-1])
      end
      if CHORDS.include? type
        CHORDS[type].each do |n|
          if relative
            notes.push(n.floor + 1)
          else
            if n == n.to_i
              notes.push scale[n%scale.length]
            else
              r = ((n*10).to_i%10)-5
              s = scale[n.to_i%scale.length]
              f = Note.fix(s) + r
              n = Note.key(f, false)
              notes.push(n)
            end
          end
        end
      else
        return [false,type]
      end
      return notes
    end

    def self.name (s)
      if s[1] == '♯' or s[1] == 'b'
        note = Note.key s[0..1], false
        type = abbr(s[2..-1])
      else
        note = Note.key s[0], false
        type = abbr(s[1..-1])
      end
      return note+type
    end
  end


  class Strat

    $chordcolors = [['#FD0202', '#F24D16', '#E88829', '#DDB439', '#D2D248', '#ABC855', '#8FBD60'], ['#FD7602', '#F2B316', '#E8E029', '#BADD39', '#92D248', '#76C855', '#64BD60'], ['#FDEA02', '#CCF216', '#97E829', '#6FDD39', '#53D248', '#55C869', '#60BD87'], ['#9CFD02', '#67F216', '#3FE829', '#39DD4F', '#48D27D', '#55C89E', '#60BDB2'], ['#29FD02', '#16F22B', '#29E86B', '#39DD9B', '#48D2BD', '#55BDC8', '#609DBD'], ['#02FD4F', '#16F291', '#29E8C3', '#39D3DD', '#48A8D2', '#5588C8', '#6072BD'], ['#02FDC3', '#16EEF2', '#29B4E8', '#3988DD', '#4868D2', '#5755C8', '#7960BD'], ['#02C3FD', '#1688F2', '#295CE8', '#393CDD', '#6848D2', '#8C55C8', '#A460BD'], ['#024FFD', '#1623F2', '#4D29E8', '#8239DD', '#A848D2', '#C155C8', '#BD60AB'], ['#2902FD', '#6F16F2', '#A529E8', '#CD39DD', '#D248BD', '#C85599', '#BD6080'], ['#9C02FD', '#D516F2', '#E829D2', '#DD39A1', '#D2487D', '#C85564', '#BD6B60'], ['#FD02EA', '#F216AA', '#E82979', '#DD3955', '#D25348', '#C87A55', '#BD9660']]
    $dists = []
    $firstfretwidth = 76
    $boardwidth = 80
    $boardend = 110
    $boardmargin = 5
    $boardstep = ( $boardwidth - $boardmargin*2 ) / 5
    $numfrets = 22

    def self.standard_tuning
      ['E2','A2','D3','G3','B3','E4']
    end

    def self.handles(st=self.standard_tuning)
      handles = []
      6.times do |h|
        x = ($boardmargin + h * $boardstep).to_s
        xx = (3+h*15)
        yx = (-68-h*44)
        t = {
          'type' => 'text',
          'x' => (xx-36).to_s,
          'y' => (yx-12).to_s,
          'text' => st[h],
          'count' => h,
          'fill' => '#666',
          'font' =>  "bold 18px 'Georgia'",
          'transform' => 'R -79',
        }
        handles.push(t)
      end
      return handles
    end

    def self.fretboard ()
      y = $firstfretwidth;
      yy = 0;
      board = []
      head = {
        'type' => 'path',
        'path' => "m 0,0 c 0.67553,-13.141072 -4.48542,-17.874924 -30.62047,-25.353202 l 93.57286,-287.670447 c 13.79673,-28.33919 54.14057,-31.93149 75.04833,-12.57035 9.11046,9.06332 20.55453,35.78224 9.28602,60.61698 -5.45523,12.0228 -17.15423,23.82984 -36.50441,32.19232 0,0 -2.81387,3.53158 -1.91422,9.86513 4.11709,28.98438 32.13336,129.84242 24.99516,141.72309 -7.13821,11.880669 -48.15894,10.032667 -52.87363,81.339695 z",
        'stroke' =>  'none',
        'fill' => '90-#8b512e-#cd8f69:10-#c07040'
      }
      board.push(head)


      body = {
        'type' => 'path',
        'path' => "m -4,770 c -4.5242,43.39873 -83.3941,32.78475 -108.7634,-11.67981 -20.7376,-36.34659 5.2806,-91.30037 -19.9816,-102.2859 -30.8976,-13.43602 -80.1227,35.57216 -72.3811,129.47097 7.3335,88.948316 57.1253,131.731505 44.9389,217.090413 -12.1864,85.358817 -110.4576,200.116007 -85.1837,318.218047 25.2739,118.10213 162.8277,135.95354 274.3877,145.03181 111.5601,9.07826 263.55221,6.37368 287.47455,-128.09349 24.6158,-138.36507 -67.0671,-209.42944 -74.31643,-304.36328 -3.18581,-41.719804 14.39068,-62.103376 22.96767,-88.367288 8.5803,-26.274115 25.80111,-44.13946 23.04036,-96.234742 -4.57647,-86.35794 -45.45078,-70.88739 -48.67796,-70.97081 -27.19304,7.98078 -15.26175,59.28649 -42.35049,85.685817 -8.8064,8.582202 -30.3951,18.925638 -49.5918,18.485334 -60.499,-1.387536 -54.4462,-20.583252 -61.4426,-35.736221 -8.599,-18.62415 -90.1201,-76.25085 -90.1201,-76.25085 z",
        'stroke' =>  'none',
        'fill' => 'maroon'
      }
      board.push(body)
      white = {
        'type' => 'path',
        'path' => "m -96,1140 c 0.098,7.01566 0.8747,14.03337 2.4142,21.22344 8.7356,48.54034 40.2199,58.7572 74.4886,53.05809 40.0337,1.66041 95.5773,-7.43657 154.943,7.6553 50.2963,12.78628 73.79222,31.93169 94.91923,51.95945 17.53567,15.74884 37.64893,32.96362 55.5543,23.46872 30.22696,-20.56269 -2.85821,-89.94559 -13.0125,-115.40769 -21.34736,-53.00201 -47.47667,-93.35326 -50.38964,-150.820522 -2.42253,-47.791858 16.95174,-74.49973817 24.01244,-96.120565 10.32302,-31.610493 24.49009,-41.3072 21.99337,-88.420203 -2.10544,-39.72965 -11.89005,-48.9677 -14.67067,-50.69193 -1.3903,-0.86212 -2.28921,-0.9382 -3.72532,-0.90891 -0.71806,0.0145 -1.44538,0.0977 -2.28269,0.24145 -0.18297,0.031 -0.46873,0.0898 -0.67735,0.12887 -0.0684,0.19233 -0.14486,0.42621 -0.76059,1.67448 -1.49359,3.02792 -3.37982,9.69246 -5.23772,18.05192 -3.60708,16.22961 -7.38026,39.85959 -25.58263,58.765547 l 0.0275,0.02835 c -0.50003,0.606339 -1.06013,1.131786 -1.57707,1.716489 -11.46688,12.97011 -26.98306,22.595111 -42.57546,25.085465 -16.2953,2.602665 -32.6136,-1.418191 -48.8761,-5.556621 -32.5252,-8.276954 -65.6194,-25.061756 -95.7875,-39.87163 -30.1681,-14.80978 -58.4564,-27.17844 -71.6229,-28.67619 -6.5833,-0.74888 -6.5511,0.23292 -6.2433,-0.0811 0.2923,-0.29824 -2.0298,2.90505 -2.0368,13.55084 15.6979,74.226032 12.888,128.553187 -6.4573,178.417869 -18.2156,46.953021 -37.3243,86.480971 -36.8373,121.528471 z",
        'stroke' =>  'none',
        'fill' => 'White'
      }
      board.push(white)
      fboard = {
          'type' => 'path',
          'path' => 'M 0 0 L 80 0 L 85 910 C 87 930 -7 930 -5 910 Z',
          'stroke' => 'none',
          'fill' => 'Black'
        }
      board.push(fboard)
      $numfrets.times do |t|
        i = [5,7,9,15,17,19,21].rindex {|a| a == t}
        if i
          circle = {
              'type' => 'circle',
              'cx' => 40,
              'cy' => yy-y/2,
              'r' => 5,
              'fill' => 'Silver'
          }
          board.push circle
        elsif t == 12
          board.push ( {
              'type' => 'circle',
              'cx' => 16,
              'cy' => yy-y/2,
              'r' => 5,
              'fill' => 'Silver'
          })
          board.push ( {
              'type' => 'circle',
              'cx' => 63,
              'cy' => yy-y/2,
              'r' => 5,
              'fill' => 'Silver'
          })
        end
        if t == 0 then w = 9 else w = 3 end
        fret = {
          'type' => 'path',
          'path' => 'M'+(-yy/184).to_s+' '+(yy).to_s+' H'+(80+yy/184).to_s,
          'stroke-width' => w,
          'stroke' => 'Gainsboro'
        }
        board.push fret
        $dists.push (yy-8)
        y /= STEP
        yy += y.round
      end
      tresh = {
          'type' => 'path',
          'path' => 'M 0 0 L 80 0 L 80 -10 L 0 -10 Z',
          'stroke' => 'none',
          'fill' => 'Black',
          'fill-opacity' => 0.6
        }
      #board.push(tresh)
      $dists.push (yy-8)
      6.times do |h|
        x = ($boardmargin + h * $boardstep).to_s
        xx = (3+h*15)
        yx = (-68-h*44)
        l = {
          'type' => 'path',
          'path' => 'M'+x+' 0 L '+(xx+5).to_s+' '+yx.to_s,
          'stroke-width' => 2.5-h/3.0,
          'stroke' => 'Silver',
        }
        board.push(l)
        c = {
          'type' => 'circle',
          'cx' => xx.to_s,
          'cy' => yx.to_s,
          'r' => 8,
          'stroke' => 'none',
          'fill' => 'r(.8,.4)#666-#ddd',
        }
        board.push(c)
      end
      6.times do |s|
        x = ($boardmargin + s * $boardstep).to_s
        xx = (s * 17 - 3).to_s
        string = {
          'type' => 'path',
          'path' => 'M'+x+' 0 L '+xx+' 1280',
          'stroke-width' => 2.5-s/3.0,
          'stroke' => 'Silver'
        }
        board.push string
      end
      return board
    end

    def self.blisters (choice=nil,strings=self.standard_tuning,scale=nil)
      blisters = {}
      if choice == nil
        return blisters.to_json
      end
      tonic = Note.key(choice[0],true)%12
        colors = $chordcolors[tonic]
      6.times do |s|
        blisterstr = []
        st = strings[s]
        t = Note.fix st
        $numfrets.times do |f|
          n = Note.key(t,false)
          i = choice.rindex {|a| a == n}
          if i
            color = colors[i]
            if i == 0 then rad = 7 else rad = 5 end
            if f == 0
              blister = {
                'type' => 'circle',
                'cx' => $boardmargin+s*$boardstep,
                'cy' => $dists[f]+8,
                'r' => rad-1,
                'count' => Note.ord2tone(t.to_i),
                'coord' => [s,f],
                'index' => i,
                'stroke' => color,
                'stroke-width' => 3,
                'fill' => 'black'
              }
              blisterstr.push blister
            else
              xc = ($dists[f]/460.0)
              blister = {
                'type' => 'circle',
                'cx' => $boardmargin-xc*2.5+s*($boardstep+xc),
                'cy' => $dists[f],
                'r' => rad,
                'count' => Note.ord2tone(t.to_i),
                'coord' => [s,f],
                'index' => i,
                'fill' => color,
                #'fill-opacity' => 1.2-f/($numfrets*1.0),
                'stroke' => 'none'
              }
              blisterstr.push blister
            end
          end
          t += 1
        end
        blisters[s] = blisterstr
      end
      legend = []
      ords = []
      choice.length.times do |c|
        nt = choice[c]
        cl = colors[c]
        o = Note.fix(nt+'4').to_i
        if c > 0 and o < ords[c-1]
          o += 12
        end
        ords.push o
        legend.push(nt+','+cl+','+o.to_s)
      end
      blisters['legend'] = (legend.join(';'))
      return blisters
    end
  end

end


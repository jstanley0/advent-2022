class Disk
  attr_accessor :root, :cwd

  def initialize
    self.root = {}
    self.cwd = []
  end

  def cd(dir)
    case dir
    when '/'
      self.cwd = []
    when '..'
      raise "oops" if cwd.empty?
      cwd.pop
    else
      cwd.push(dir)
    end
  end

  def dir(name)
    dirent[name] = {}
  end

  def file(size, name)
    dirent[name] = size.to_i
  end

  def print
    pp root
  end

  def size(sizes, name = '/', dir = root)
    sz = 0
    dir.each do |k, v|
      if v.is_a?(Integer)
        sz += v
      else
        sz += size(sizes, File.join(name, k), v)
      end
    end
    sizes[name] = sz
  end

  private def dirent
    cwd.any? ? root.dig(*cwd) : root
  end
end

disk = Disk.new
ARGF.each do |cmd|
  case cmd
  when /^\$ cd (.+)/ then disk.cd $1
  when /^dir (.+)/ then disk.dir $1
  when /^(\d+) (.+)/ then disk.file $1, $2
  end
end
disk.print

sizes = {}
du = disk.size(sizes)
pp sizes

p sizes.values.select{_1 <= 100000}.sum

free = 70000000 - du
need = 30000000 - free
p sizes.values.select{_1 >= need}.min

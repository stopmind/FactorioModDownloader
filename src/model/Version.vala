
class Version {
  public int major;
  public int minor;
  public int patch;

  public Version(int maj, int min, int pat) {
    major = maj;
    minor = min;
    patch = pat;
  }

  public Version.from_string(string version) {
    string[] parts = version.split(".");
  
    major = int.parse(parts[0]);
    minor = int.parse(parts[1]);
    
    if (parts.length == 3) {
      patch = int.parse(parts[2]);
    } else {
      patch = 0;
    }
  }

  public string to_string() {
    return "%i.%i.%i".printf(major, minor, patch);
  }

  public bool equal(Version ver2) {  
    return (
      major == ver2.major &&
      minor == ver2.minor &&
      patch == ver2.patch
    );
  }

  public bool greeter_equal(Version ver2) {  
    if (major > ver2.major) return true;
    if (major < ver2.major) return false;

    if (minor > ver2.minor) return true;
    if (minor < ver2.minor) return false;

    if (patch > ver2.patch) return true;
    if (patch < ver2.patch) return false;
    
    return true;
  }
}

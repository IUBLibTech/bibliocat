# An extension of File to provide the UploadedFile interface expected by Worthwhile.

class IngestableFile < File
  def original_filename
    File.basename(self.path)
  end
end
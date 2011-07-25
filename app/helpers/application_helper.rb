module ApplicationHelper
  def pass_thru_bad(&block)
    yield
  end

  def pass_thru_good(&block)
    haml_concat(capture_haml(&block))
  end
end

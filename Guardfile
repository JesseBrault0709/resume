guard 'shell' do
  watch(%r(src/.+)) do |match|
    unless match.nil? || match[0].nil? || match[0].empty?
      Guard::UI.logger.info("#{match[0]} modified")
      system './resume build', exception: true
    end
  end
end

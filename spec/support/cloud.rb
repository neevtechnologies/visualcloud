def cloud_should_be_initialized(access_id, secret_key)
  cloud = OpenStruct.new
  Cloudster::Cloud.should_receive(:new).with({:access_key_id=>access_id, :secret_access_key=>secret_key}).and_return cloud
  return cloud
end

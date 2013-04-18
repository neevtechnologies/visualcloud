class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :aws_access_key, :aws_secret_key
  # TODO : Code Review : Maybe this should be moved to project level ?
  attr_encrypted :aws_secret_key, :key => VisualCloudConfig[:attr_encryption_salt]
  has_and_belongs_to_many :projects
  before_create :set_demo_aws_creds

  # Returns key pairs and security groups, specific to given region from aws servers
  def get_key_pair_and_security_groups(region = nil)
    return [['keyName' => 'demo_key_pair'],['groupName' => 'demo_security_group']] if (aws_access_key == 'demo')
    cloud = Cloudster::Cloud.new(access_key_id: aws_access_key, secret_access_key: aws_secret_key, region: region)
    key_pairs = cloud.get_key_pairs
    security_groups = cloud.get_security_groups
    return key_pairs, security_groups
  end

  #Users with demo creds can do a whole walkthrough
  #without actually firing AWS API calls
  private
    def set_demo_aws_creds
      self.aws_access_key = 'demo' if self.aws_access_key.nil?
    end

end

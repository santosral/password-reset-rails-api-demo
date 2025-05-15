class AccessToken
  def self.encode(sub:, jti:, exp:, key:)
    payload = {}
    payload[:sub] = sub
    payload[:jti] = jti
    payload[:exp] = exp

    headers = {}
    headers[:kid] = "hmac"

    JWT.encode(payload, key, "HS256", headers)
  end

  def self.decode(token:, key:)
    decoded = JWT.decode(token, key, true, { algorithm: "HS256" })[0]
    HashWithIndifferentAccess.new(decoded)
  end
end

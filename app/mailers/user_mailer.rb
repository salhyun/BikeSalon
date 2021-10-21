class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #
  def welcome(user)
    @user = user
    mail to: @user.account, subject: "[바이크살롱] 환영합니다!!"
  end
  def verify(user)
    @user = user
    mail to: @user.account, subject: "[바이크살롱] 인증하기!"
  end
  def resetPassword(user)
    @user = user
    mail to: @user.account, subject: "[바이크살롱] 비밀번호 다시 설정하기"
  end

  def warning(user, category, content)
    @user = user
    @category = category
    @content = content
    mail to: @user.account, subject: "[바이크살롱] 사용자 경고"
  end
  def suspend(user)
    @user = user
    mail to: @user.account, subject: "[바이크살롱] 사용자 정지"
  end
  def propose(user, content)
    @user = user
    @content = content
    mail to: ENV['masterAccount'], subject: "[바이크살롱] " + @user.name + "님의 제안 및 의견이 도착했습니다."
  end
  def reflection(user, content)
    @user = user
    @content = content
    mail to: ENV['masterAccount'], subject: "[바이크살롱] " + @user.name + "님의 반성문이 도착했습니다."
  end

  def shootMail(user, subject, content)
    @user = user
    @content = content
    mail to: @user.account, subject: subject
  end

end

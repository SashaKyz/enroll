When(/I visit the Insured portal$/) do
  @browser.goto("http://localhost:3000/")
  @browser.a(text: /consumer\/family portal/i).wait_until_present
  @browser.a(text: /consumer\/family portal/i).click
  screenshot("individual_start")
end

Then(/Individual creates HBX account$/) do
  @browser.button(class: /interaction-click-control-create-account/).wait_until_present
  @browser.text_field(class: /interaction-field-control-user-email/).set("taylor.york@example.com")
  @browser.text_field(class: /interaction-field-control-user-password/).set("aA1!aA1!aA1!")
  @browser.text_field(class: /interaction-field-control-user-password-confirmation/).set("aA1!aA1!aA1!")
  screenshot("create_account")
  scroll_then_click(@browser.input(value: "Create account"))
end

When(/user goes to register as an individual$/) do
  @browser.button(class: /interaction-click-control-continue/).wait_until_present
  @browser.text_field(class: /interaction-field-control-person-first-name/).set("Taylor")
  @browser.text_field(class: /interaction-field-control-person-middle-name/).set("K")
  @browser.text_field(class: /interaction-field-control-person-last-name/).set("York")
  @browser.text_field(class: /interaction-field-control-person-name-sfx/).set("Jr")
  @browser.text_field(class: /interaction-field-control-jq-datepicker-ignore-person-dob/).set("05/23/1969")
  @browser.text_field(class: /interaction-field-control-person-ssn/).set("677991234")
  @browser.text_field(class: /interaction-field-control-person-ssn/).click
  expect(@browser.text_field(class: /interaction-field-control-person-ssn/).value).to_not eq("")
  @browser.checkbox(class: /interaction-choice-control-value-person-no-ssn/).fire_event("onclick")
  expect(@browser.text_field(class: /interaction-field-control-person-ssn/).value).to eq("")
  @browser.text_field(class: /interaction-field-control-person-ssn/).set("677991234")
  @browser.radio(class: /interaction-choice-control-value-radio-male/).fire_event("onclick")
  screenshot("register")
  @browser.button(class: /interaction-click-control-continue/).click
end

Then(/user should see button to continue as an individual/) do
  @browser.a(text: /continue as an individual/i).wait_until_present
  screenshot("no_match")
  expect(@browser.a(text: /continue as an individual/i).visible?).to be_truthy
end

Then(/Individual should click on Individual market for plan shopping/) do

  @browser.a(text: /continue as an individual/i).wait_until_present
  @browser.a(text: /continue as an individual/i).click
end

Then(/Individual should see a form to enter personal information/) do
  @browser.button(class: /interaction-click-control-continue/).wait_until_present
  screenshot("personal_form_top")
  @browser.radio(class: /interaction-choice-control-value-person-us-citizen-true/).fire_event("onclick")
  @browser.radio(class: /interaction-choice-control-value-person-naturalized-citizen-false/).wait_while_present
  @browser.radio(class: /interaction-choice-control-value-person-naturalized-citizen-false/).fire_event("onclick")
  @browser.text_field(class: /interaction-field-control-person-addresses-attributes-0-address-1/).set("4900 USAA BLVD")
  @browser.text_field(class: /interaction-field-control-person-addresses-attributes-0-address-2/).set("Suite 220")
  @browser.text_field(class: /interaction-field-control-person-addresses-attributes-0-city/).set("Sacramento")
  select_state = @browser.divs(text: /SELECT STATE/).last
  select_state.click
  scroll_then_click(@browser.li(text: /CA/))
  @browser.text_field(class: /interaction-field-control-person-addresses-attributes-0-zip/).set("78218")
  @browser.text_field(class: /interaction-field-control-person-phones-attributes-0-full-phone-number/).set("1110009999")
  @browser.text_field(class: /interaction-field-control-person-emails-attributes-0-address/).set("taylor.york@example.com")
  screenshot("personal_form_bottom")
end

When(/Individual clicks on Save and Exit/) do
   click_when_present(@browser.link(class: /interaction-click-control-save---exit/))
end

When(/Individual clicks on continue button/) do
  click_when_present(@browser.button(class: /interaction-click-control-continue/))
end

When (/Individual resumes enrollment/) do
  @browser.a(text: /consumer\/family portal/i).wait_until_present
  @browser.a(text: /consumer\/family portal/i).click
  wait_and_confirm_text(/Sign In Existing Account/)
  click_when_present(@browser.link(class: /interaction-click-control-sign-in-existing-account/))
  @browser.text_field(class: /interaction-field-control-user-email/).set("taylor.york@example.com")
  @browser.text_field(class: /interaction-field-control-user-password/).set("aA1!aA1!aA1!")
  @browser.element(class: /interaction-click-control-sign-in/).click
  sleep(2)
  expect(@browser.text_field(class: /interaction-field-control-person-addresses-attributes-0-address-1/).value).to eq("4900 USAA BLVD")
end

Then("Individual should see identity verification page and clicks on submit") do
  @browser.radio(class: /interaction-choice-control-value-agreement-agree/).wait_until_present
  @browser.radio(class: /interaction-choice-control-value-agreement-agree/).click
  @browser.a(class: /interaction-click-control-continue/).wait_until_present
  @browser.a(class: /interaction-click-control-continue/).click
  @browser.radio(class: /interaction-choice-control-value-interactive-verification-questions-attributes-0-response-id-a/).wait_until_present
  @browser.radio(class: /interaction-choice-control-value-interactive-verification-questions-attributes-0-response-id-a/).set
  @browser.radio(class: /interaction-choice-control-value-interactive-verification-questions-attributes-1-response-id-c/).set
  @browser.button(class: /interaction-click-control-submit/).wait_until_present
  @browser.button(class: /interaction-click-control-submit/).click
  screenshot("identify_verification")
  @browser.a(class: /interaction-click-control-override-identity-verification/).wait_until_present
  screenshot("override")
  @browser.a(class: /interaction-click-control-override-identity-verification/).click
end

Then(/Individual should see the dependents form/) do
  @browser.a(text: /Add Member/).wait_until_present
  screenshot("dependents")
  expect(@browser.a(text: /Add Member/).visible?).to be_truthy
end

And(/Individual clicks on add member button/) do
  @browser.a(text: /Add Member/).wait_until_present
  @browser.a(text: /Add Member/).click
  @browser.text_field(id: /dependent_first_name/).wait_until_present
  @browser.text_field(id: /dependent_first_name/).set("Mary")
  @browser.text_field(id: /dependent_middle_name/).set("K")
  @browser.text_field(id: /dependent_last_name/).set("York")
  @browser.text_field(name: 'jq_datepicker_ignore_dependent[dob]').set('01/15/2011')
  @browser.text_field(id: /dependent_ssn/).set("098098111")
  input_field = @browser.div(class: /selectric-wrapper/)
  input_field.click
  input_field.li(text: /Child/).click
  @browser.radio(id: /radio_female/).fire_event("onclick")
  @browser.radio(id: /dependent_us_citizen_true/).fire_event("onclick")
  @browser.radio(id: /dependent_naturalized_citizen_false/).wait_while_present
  @browser.radio(id: /dependent_naturalized_citizen_false/).fire_event("onclick")
  screenshot("add_member")
  scroll_then_click(@browser.button(text: /Confirm Member/))
  @browser.button(text: /Confirm Member/).wait_while_present
end

And(/Individual again clicks on add member button/) do
  @browser.a(text: /Add Member/).wait_until_present
  @browser.a(text: /Add Member/).click
  @browser.text_field(id: /dependent_first_name/).wait_until_present
  @browser.text_field(id: /dependent_first_name/).set("Robert")
  @browser.text_field(id: /dependent_middle_name/).set("K")
  @browser.text_field(id: /dependent_last_name/).set("York")
  @browser.text_field(name: 'jq_datepicker_ignore_dependent[dob]').set('01/15/2013')
  @browser.text_field(id: /dependent_ssn/).set("198021122")
  input_field = @browser.div(class: /selectric-wrapper/)
  input_field.click
  input_field.li(text: /Child/).click
  @browser.radio(id: /radio_male/).fire_event("onclick")
  @browser.radio(id: /dependent_us_citizen_false/).fire_event("onclick")
  @browser.radio(id: /dependent_eligible_immigration_status_true/).wait_while_present
  @browser.radio(id: /dependent_eligible_immigration_status_true/).fire_event("onclick")
  scroll_then_click(@browser.button(text: /Confirm Member/))
  @browser.button(text: /Confirm Member/).wait_while_present
end


And(/I click on continue button on household info form/) do
  click_when_present(@browser.a(text: /continue/i))
end

And(/I click on continue button on group selection page/) do
  if !HbxProfile.find_by_state_abbreviation('DC').under_open_enrollment?
    click_when_present(@browser.a(text: /I've had a baby/))

    @browser.text_field(id: /qle_date/).wait_until_present
    @browser.text_field(id: /qle_date/).set(5.days.ago.strftime('%m/%d/%Y'))

    qle_form = @browser.div(class: /qle-form/)
    click_when_present(qle_form.a(class: /interaction-click-control-continue/))

    @browser.div(class: /success-info/).wait_until_present
    @browser.div(class: /success-info/).button(class: /interaction-click-control-continue/).click
  end

  click_when_present(@browser.button(class: /interaction-click-control-continue/))
end

And(/I select a plan on plan shopping page/) do
  screenshot("plan_shopping")
  click_when_present(@browser.a(text: /Select Plan/))
end

And(/I click on purchase button on confirmation page/) do
  click_when_present(@browser.checkbox(class: /interaction-choice-control-value-terms-check-thank-you/))
  @browser.text_field(class: /interaction-field-control-first-name-thank-you/).set("Taylor")
  @browser.text_field(class: /interaction-field-control-last-name-thank-you/).set("York")
  screenshot("purchase")
  click_when_present(@browser.a(text: /purchase/i))
end

And(/I click on continue button to go to the individual home page/) do
  click_when_present(@browser.a(text: /go to my account/i))
end

And(/I should see the individual home page/) do
  @browser.element(text: /my dc health link/i).wait_until_present
  screenshot("my_account")
  click_when_present(@browser.a(class: /interaction-click-control-documents/))
  expect(@browser.element(text: /Documents/i).visible?).to be_truthy
  click_when_present(@browser.a(class: /interaction-click-control-manage-family/))
  expect(@browser.element(text: /manage family/i).visible?).to be_truthy
  click_when_present(@browser.a(class: /interaction-click-control-my-dc-health-link/))
  expect(@browser.element(text: /my dc health link/i).visible?).to be_truthy
end

class GroupSelectionLogics

  def initialize(params)
    params = params
    person_id = params.require(:person_id)
    @person = Person.find(person_id)
    @family = @person.primary_family
    @coverage_household = @family.active_household.immediate_family_coverage_household
    @hbx_enrollment = HbxEnrollment.find(params[:hbx_enrollment_id]) if params[:hbx_enrollment_id].present?

    if params[:employee_role_id].present?
      emp_role_id = params.require(:employee_role_id)
      @employee_role = @person.employee_roles.detect { |emp_role| emp_role.id.to_s == emp_role_id.to_s }
      @role = @employee_role
    elsif params[:resident_role_id].present?
      @resident_role = @person.resident_role
      @role = @resident_role
    else
      @consumer_role = @person.consumer_role
      @role = @consumer_role
    end

    @change_plan = params[:change_plan].present? ? params[:change_plan] : ''
    @coverage_kind = params[:coverage_kind].present? ? params[:coverage_kind] : 'health'
    @enrollment_kind = params[:enrollment_kind].present? ? params[:enrollment_kind] : ''
    @shop_for_plans = params[:shop_for_plans].present? ? params{:shop_for_plans} : ''
    @employee_role = @person.active_employee_roles.first if @employee_role.blank? and @person.has_active_employee_role?
  end

  def add_new_benefit_group(params,session)
    @market_kind = select_market(@person, params)
    @resident = Person.find(params[:person_id]) if Person.find(params[:person_id]).resident_role?
    if @market_kind == 'individual' || (@person.try(:has_active_employee_role?) && @person.try(:has_active_consumer_role?)) || @resident
      if params[:hbx_enrollment_id].present?
        session[:pre_hbx_enrollment_id] = params[:hbx_enrollment_id]
        pre_hbx = HbxEnrollment.find(params[:hbx_enrollment_id])
        pre_hbx.update_current(changing: true) if pre_hbx.present?
      end
      correct_effective_on = HbxEnrollment.calculate_effective_on_from(
          market_kind: 'individual',
          qle: (@change_plan == 'change_by_qle' or @enrollment_kind == 'sep'),
          family: @family,
          employee_role: nil,
          benefit_group: nil,
          benefit_sponsorship: HbxProfile.current_hbx.try(:benefit_sponsorship))
      @benefit = HbxProfile.current_hbx.benefit_sponsorship.benefit_coverage_periods.select{|bcp| bcp.contains?(correct_effective_on)}.first.benefit_packages.select{|bp|  bp[:title] == "individual_health_benefits_#{correct_effective_on.year}"}.first
    end
    if (@change_plan == 'change_by_qle' or @enrollment_kind == 'sep')
      @disable_market_kind = @market_kind == "shop" ? "individual" : "shop"
    end
    insure_hbx_enrollment_for_shop_qle_flow
    @waivable = @hbx_enrollment.can_complete_shopping? if @hbx_enrollment.present?
    @new_effective_on = HbxEnrollment.calculate_effective_on_from(
        market_kind:@market_kind,
        qle: (@change_plan == 'change_by_qle' or @enrollment_kind == 'sep'),
        family: @family,
        employee_role: @employee_role,
        benefit_group: @employee_role.present? ? @employee_role.benefit_group : nil,
        benefit_sponsorship: HbxProfile.current_hbx.try(:benefit_sponsorship))

    generate_coverage_family_members_for_cobra
    # Set @new_effective_on to the date choice selected by user if this is a QLE with date options available.
    @new_effective_on = Date.strptime(params[:effective_on_option_selected], '%m/%d/%Y') if params[:effective_on_option_selected].present?
  end

  private

  def build_hbx_enrollment
    case @market_kind
      when 'shop'
        if @hbx_enrollment.present?
          @change_plan = 'change_by_qle' if @hbx_enrollment.is_special_enrollment?
          if @employee_role == @hbx_enrollment.employee_role
            benefit_group = @hbx_enrollment.benefit_group
            benefit_group_assignment = @hbx_enrollment.benefit_group_assignment
          else
            benefit_group = @employee_role.benefit_group
            benefit_group_assignment = @employee_role.census_employee.active_benefit_group_assignment
          end
        end
        @coverage_household.household.new_hbx_enrollment_from(
            employee_role: @employee_role,
            resident_role: @person.resident_role,
            coverage_household: @coverage_household,
            benefit_group: benefit_group,
            benefit_group_assignment: benefit_group_assignment,
            qle: (@change_plan == 'change_by_qle' or @enrollment_kind == 'sep'))
      when 'individual'
        @coverage_household.household.new_hbx_enrollment_from(
            consumer_role: @person.consumer_role,
            resident_role: @person.resident_role,
            coverage_household: @coverage_household,
            qle: (@change_plan == 'change_by_qle' or @enrollment_kind == 'sep'))
      when 'coverall'
        @coverage_household.household.new_hbx_enrollment_from(
            consumer_role: @person.consumer_role,
            resident_role: @person.resident_role,
            coverage_household: @coverage_household,
            qle: (@change_plan == 'change_by_qle' or @enrollment_kind == 'sep'))
    end
  end

  def insure_hbx_enrollment_for_shop_qle_flow
    if @market_kind == 'shop' && (@change_plan == 'change_by_qle' || @enrollment_kind == 'sep') && @hbx_enrollment.blank?
      @hbx_enrollment = @family.active_household.hbx_enrollments.shop_market.enrolled_and_renewing.effective_desc.detect { |hbx| hbx.may_terminate_coverage? }
    end
  end

  def generate_coverage_family_members_for_cobra
    if @market_kind == 'shop' && !(@change_plan == 'change_by_qle' || @enrollment_kind == 'sep') && @employee_role.present? && @employee_role.is_cobra_status?
      hbx_enrollment = @family.active_household.hbx_enrollments.shop_market.enrolled_and_renewing.effective_desc.detect { |hbx| hbx.may_terminate_coverage? }
      if hbx_enrollment.present?
        @coverage_family_members_for_cobra = hbx_enrollment.hbx_enrollment_members.map(&:family_member)
      end
    end
  end

  def select_market(person, params)
    return params[:market_kind] if params[:market_kind].present?
    if @person.try(:has_active_employee_role?)
      'shop'
    elsif @person.try(:has_active_consumer_role?)
      'individual'
    elsif @person.try(:has_active_resident_role?)
      'coverall'
    else
      nil
    end
  end

end

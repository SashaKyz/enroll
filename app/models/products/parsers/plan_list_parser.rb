require Rails.root.join('app', 'models', 'products', 'parsers', 'plan_parser')

module Parser
  class PlanListParser
    include HappyMapper

    #register_namespace "xmlns", "http://vo.ffe.cms.hhs.gov"
    #register_namespace "impl", "http://vo.ffe.cms.hhs.gov"
    #register_namespace "targetNamespace", "http://vo.ffe.cms.hhs.gov"
    #register_namespace "xsd", "http://www.w3.org/2001/XMLSchema"

    tag 'plansList'

    has_many :plans, Parser::PlanParser, tag: "plans"

    #has_many :benefits, Parser::BenifitsParser, xpath: 'benefitsList/benefits'

    def to_hash
      {
          plans: plans.map(&:to_hash)
      }
    end
  end
end

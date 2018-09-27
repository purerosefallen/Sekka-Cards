--捷号作战，苏里高海战
local m=77708000
local cm=_G["c"..m]
xpcall(function() require("expansions/script/c37564765") end,function() require("script/c37564765") end)
cm.dfc_front_side=m+1
function cm.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE+EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCost(Senya.ForbiddenCost())
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(aux.bfgcost)
	e1:SetCondition(aux.exccon)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local ex1=Effect.CreateEffect(c)
		ex1:SetType(EFFECT_TYPE_FIELD)
		ex1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ex1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		ex1:SetTargetRange(0xff,0xff)
		ex1:SetValue(LOCATION_DECKBOT)
		ex1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(ex1,tp)
		local ex2=ex1:Clone()
		ex2:SetCode(EFFECT_CANNOT_TO_GRAVE)
		ex2:SetTargetRange(LOCATION_DECK+LOCATION_EXTRA,LOCATION_DECK+LOCATION_EXTRA)
		ex2:SetTarget(function(e,c)
			return c:IsLocation(LOCATION_DECK)
				or (c:IsLocation(LOCATION_EXTRA) and (c:GetOriginalType() & TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)~=0)
		end)
		Duel.RegisterEffect(ex2,tp)
	end)
	c:RegisterEffect(e1)
end
function cm.filter(c,tp,tempc)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsLocation(LOCATION_GRAVE) and c:GetPreviousControler()==tp and c:IsCanBeRitualMaterial(tempc)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local l=e:GetLabel()
	e:SetLabel(0)
	if chk==0 then
		local c=e:GetHandler()
		if not Senya.IsDFCTransformable(c) or l~=1 then return false end
		local tempc=Senya.GetDFCBackSideCard(c)	
		if not tempc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true) then return false end
		local mg=eg:Filter(cm.filter,nil,tp,tempc)
		return Senya.CheckRitualMaterial(tempc,mg,tp,tempc:GetLevel(),nil,true)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,LOCATION_GRAVE,tp)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	e:SetLabel(1)
	if not cm.target(e,tp,eg,ep,ev,re,r,rp,0) or c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e) then return end
	local tempc=Senya.GetDFCBackSideCard(c)
	local mg=eg:Filter(cm.filter,nil,tp,tempc)
	local mat=Senya.SelectRitualMaterial(tempc,mg,tp,tempc:GetLevel(),nil,true)
	c:SetMaterial(mat)
	Duel.Remove(mat,POS_FACEUP,REASON_EFFECT)
	Duel.BreakEffect()
	Senya.TransformDFCCard(c)
	Duel.SpecialSummon(c,SUMMON_TYPE_RITUAL,tp,tp,true,true,POS_FACEUP)
	c:CompleteProcedure()
end
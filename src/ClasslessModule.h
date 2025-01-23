#ifndef CMANGOS_MODULE_CLASSLESS_H
#define CMANGOS_MODULE_CLASSLESS_H

#include "Module.h"
#include "ClasslessModuleConfig.h"

namespace cmangos_module
{
    class ClasslessModule : public Module
    {
    public:
        BalancingModule();
        const ClasslessModuleConfig* GetConfig() const override;
    };
}
#endif

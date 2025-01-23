#include "ClasslessModule.h"

namespace cmangos_module
{
    ClasslessModule::ClasslessModule()
    : Module("Classless", new ClasslessModuleConfig())
    {

    }

    const ClasslessModuleConfig* ClasslessModule::GetConfig() const
    {
        return (ClasslessModuleConfig*)Module::GetConfig();
    }
}
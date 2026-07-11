$solutionContent = @'
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
VisualStudioVersion = 17.0.31903.59
MinimumVisualStudioVersion = 10.0.40219.1
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "ResourceAlchemyHacker_CLI", "ResourceAlchemyHacker_CLI\ResourceAlchemyHacker_CLI.vcxproj", "{11111111-1111-1111-1111-111111111111}"
EndProject
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "ResourceAlchemyHacker_GUI", "ResourceAlchemyHacker_GUI\ResourceAlchemyHacker_GUI.vcxproj", "{22222222-2222-2222-2222-222222222222}"
EndProject
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "ResourceAlchemyHacker_ShellExt", "ResourceAlchemyHacker_ShellExt\ResourceAlchemyHacker_ShellExt.vcxproj", "{33333333-3333-3333-3333-333333333333}"
EndProject
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|x64 = Debug|x64
		Debug|x86 = Debug|x86
		Release|x64 = Release|x64
		Release|x86 = Release|x86
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{11111111-1111-1111-1111-111111111111}.Debug|x64.ActiveCfg = Debug|x64
		{11111111-1111-1111-1111-111111111111}.Debug|x64.Build.0 = Debug|x64
		{11111111-1111-1111-1111-111111111111}.Debug|x86.ActiveCfg = Debug|Win32
		{11111111-1111-1111-1111-111111111111}.Debug|x86.Build.0 = Debug|Win32
		{11111111-1111-1111-1111-111111111111}.Release|x64.ActiveCfg = Release|x64
		{11111111-1111-1111-1111-111111111111}.Release|x64.Build.0 = Release|x64
		{11111111-1111-1111-1111-111111111111}.Release|x86.ActiveCfg = Release|Win32
		{11111111-1111-1111-1111-111111111111}.Release|x86.Build.0 = Release|Win32
		{22222222-2222-2222-2222-222222222222}.Debug|x64.ActiveCfg = Debug|x64
		{22222222-2222-2222-2222-222222222222}.Debug|x64.Build.0 = Debug|x64
		{22222222-2222-2222-2222-222222222222}.Debug|x86.ActiveCfg = Debug|Win32
		{22222222-2222-2222-2222-222222222222}.Debug|x86.Build.0 = Debug|Win32
		{22222222-2222-2222-2222-222222222222}.Release|x64.ActiveCfg = Release|x64
		{22222222-2222-2222-2222-222222222222}.Release|x64.Build.0 = Release|x64
		{22222222-2222-2222-2222-222222222222}.Release|x86.ActiveCfg = Release|Win32
		{22222222-2222-2222-2222-222222222222}.Release|x86.Build.0 = Release|Win32
		{33333333-3333-3333-3333-333333333333}.Debug|x64.ActiveCfg = Debug|x64
		{33333333-3333-3333-3333-333333333333}.Debug|x64.Build.0 = Debug|x64
		{33333333-3333-3333-3333-333333333333}.Debug|x86.ActiveCfg = Debug|Win32
		{33333333-3333-3333-3333-333333333333}.Debug|x86.Build.0 = Debug|Win32
		{33333333-3333-3333-3333-333333333333}.Release|x64.ActiveCfg = Release|x64
		{33333333-3333-3333-3333-333333333333}.Release|x64.Build.0 = Release|x64
		{33333333-3333-3333-3333-333333333333}.Release|x86.ActiveCfg = Release|Win32
		{33333333-3333-3333-3333-333333333333}.Release|x86.Build.0 = Release|Win32
	EndGlobalSection
EndGlobal
'@

$solutionContent | Out-File -FilePath "C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\ResourceAlchemyHacker.sln" -Encoding UTF8

$vcxprojCLI = @'
<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemGroup Label="ProjectConfigurations">
    <ProjectConfiguration Include="Debug|Win32">
      <Configuration>Debug</Configuration>
      <Platform>Win32</Platform>
    </ProjectConfiguration>
    <ProjectConfiguration Include="Release|Win32">
      <Configuration>Release</Configuration>
      <Platform>Win32</Platform>
    </ProjectConfiguration>
    <ProjectConfiguration Include="Debug|x64">
      <Configuration>Debug</Configuration>
      <Platform>x64</Platform>
    </ProjectConfiguration>
    <ProjectConfiguration Include="Release|x64">
      <Configuration>Release</Configuration>
      <Platform>x64</Platform>
    </ProjectConfiguration>
  </ItemGroup>
  <PropertyGroup Label="Globals">
    <VCProjectVersion>16.0</VCProjectVersion>
    <Keyword>Win32Proj</Keyword>
    <ProjectGuid>{11111111-1111-1111-1111-111111111111}</ProjectGuid>
    <RootNamespace>ResourceAlchemyHackerCLI</RootNamespace>
    <WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>
  </PropertyGroup>
  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.Default.props" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
    <ConfigurationType>Application</ConfigurationType>
    <UseDebugLibraries>true</UseDebugLibraries>
    <PlatformToolset>v143</PlatformToolset>
    <MinimumRequiredVersion>6.00</MinimumRequiredVersion>
    <CharacterSet>Unicode</CharacterSet>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'" Label="Configuration">
    <ConfigurationType>Application</ConfigurationType>
    <UseDebugLibraries>false</UseDebugLibraries>
    <PlatformToolset>v143</PlatformToolset>
    <MinimumRequiredVersion>6.00</MinimumRequiredVersion>
    <WholeProgramOptimization>true</WholeProgramOptimization>
    <CharacterSet>Unicode</CharacterSet>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x64'" Label="Configuration">
    <ConfigurationType>Application</ConfigurationType>
    <UseDebugLibraries>true</UseDebugLibraries>
    <PlatformToolset>v143</PlatformToolset>
    <MinimumRequiredVersion>6.00</MinimumRequiredVersion>
    <CharacterSet>Unicode</CharacterSet>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|x64'" Label="Configuration">
    <ConfigurationType>Application</ConfigurationType>
    <UseDebugLibraries>false</UseDebugLibraries>
    <PlatformToolset>v143</PlatformToolset>
    <MinimumRequiredVersion>6.00</MinimumRequiredVersion>
    <WholeProgramOptimization>true</WholeProgramOptimization>
    <CharacterSet>Unicode</CharacterSet>
  </PropertyGroup>
  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.props" />
  <ImportGroup Label="ExtensionSettings">
  </ImportGroup>
  <ImportGroup Label="Shared">
  </ImportGroup>
  <PropertyGroup Label="UserMacros" />
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
    <ClCompile>
      <WarningLevel>Level3</WarningLevel>
      <SDLCheck>true</SDLCheck>
      <PreprocessorDefinitions>WIN32;_DEBUG;_CONSOLE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <ConformanceMode>true</ConformanceMode>
    </ClCompile>
    <Link>
      <SubSystem>Console</SubSystem>
      <GenerateDebugInformation>true</GenerateDebugInformation>
    </Link>
  </ItemDefinitionGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">
    <ClCompile>
      <WarningLevel>Level3</WarningLevel>
      <FunctionLevelLinking>true</FunctionLevelLinking>
      <IntrinsicFunctions>true</IntrinsicFunctions>
      <SDLCheck>true</SDLCheck>
      <PreprocessorDefinitions>WIN32;NDEBUG;_CONSOLE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <ConformanceMode>true</ConformanceMode>
    </ClCompile>
    <Link>
      <SubSystem>Console</SubSystem>
      <EnableCOMDATFolding>true</EnableCOMDATFolding>
      <OptimizeReferences>true</OptimizeReferences>
      <GenerateDebugInformation>true</GenerateDebugInformation>
    </Link>
  </ItemDefinitionGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x64'">
    <ClCompile>
      <WarningLevel>Level3</WarningLevel>
      <SDLCheck>true</SDLCheck>
      <PreprocessorDefinitions>_DEBUG;_CONSOLE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <ConformanceMode>true</ConformanceMode>
    </ClCompile>
    <Link>
      <SubSystem>Console</SubSystem>
      <GenerateDebugInformation>true</GenerateDebugInformation>
    </Link>
  </ItemDefinitionGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Release|x64'">
    <ClCompile>
      <WarningLevel>Level3</WarningLevel>
      <FunctionLevelLinking>true</FunctionLevelLinking>
      <IntrinsicFunctions>true</IntrinsicFunctions>
      <SDLCheck>true</SDLCheck>
      <PreprocessorDefinitions>NDEBUG;_CONSOLE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <ConformanceMode>true</ConformanceMode>
    </ClCompile>
    <Link>
      <SubSystem>Console</SubSystem>
      <EnableCOMDATFolding>true</EnableCOMDATFolding>
      <OptimizeReferences>true</OptimizeReferences>
      <GenerateDebugInformation>true</GenerateDebugInformation>
    </Link>
  </ItemDefinitionGroup>
  <ItemGroup>
    <ClCompile Include="main.cpp" />
  </ItemGroup>
  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.targets" />
  <ImportGroup Label="ExtensionTargets">
  </ImportGroup>
</Project>
'@

$vcxprojCLI | Out-File -FilePath "C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\ResourceAlchemyHacker_CLI\ResourceAlchemyHacker_CLI.vcxproj" -Encoding UTF8

$vcxprojGUI = $vcxprojCLI -replace "ResourceAlchemyHackerCLI", "ResourceAlchemyHackerGUI" -replace "11111111-1111-1111-1111-111111111111", "22222222-2222-2222-2222-222222222222" -replace "_CONSOLE", "_WINDOWS" -replace "Console", "Windows"
$vcxprojGUI | Out-File -FilePath "C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\ResourceAlchemyHacker_GUI\ResourceAlchemyHacker_GUI.vcxproj" -Encoding UTF8

$vcxprojExt = $vcxprojCLI -replace "ResourceAlchemyHackerCLI", "ResourceAlchemyHackerShellExt" -replace "11111111-1111-1111-1111-111111111111", "33333333-3333-3333-3333-333333333333" -replace "Application", "DynamicLibrary" -replace "Console", "Windows" -replace "_CONSOLE", "_WINDOWS;_USRDLL;SHELLEXT_EXPORTS"
$vcxprojExt | Out-File -FilePath "C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\ResourceAlchemyHacker_ShellExt\ResourceAlchemyHacker_ShellExt.vcxproj" -Encoding UTF8


